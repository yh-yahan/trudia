#include "CheckoutService.h"

#include <cmath>
#include "../printing/EscPosBuilder.h"

constexpr qint64 CURRENCY_SCALE = 100; // cents

CheckoutService::CheckoutService(OrderSessionRepository &orderSessionRepo,
                                 OrderRepository &orderRepo,
                                 OrderItemRepository &orderItemRepo,
                                 RestaurantRepository &restaurantRepo,
                                 PrinterSettingRepository &printerRepo,
                                 TableRepository &tableRepo,
                                 MembershipRepository &membershipRepo,
                                 ReceiptFormatter &formatter,
                                 NetworkPrinterService &printerService,
                                 TaxCalculationService &taxCalculationService,
                                 MembershipService &membershipService)
    : m_orderSessionRepo(orderSessionRepo),
    m_orderRepo(orderRepo),
    m_orderItemRepo(orderItemRepo),
    m_restaurantRepo(restaurantRepo),
    m_printerRepo(printerRepo),
    m_membershipRepo(membershipRepo),
    m_formatter(formatter),
    m_printerService(printerService),
    m_taxCalculationService(taxCalculationService),
    m_tableRepo(tableRepo),
    m_membershipService(membershipService) {}

QVariantList CheckoutService::getActiveOrdersForCheckout() const
{
    QVariantList result;

    auto activeSessions = m_orderSessionRepo.getAllActiveOrderSessions();

    for (const auto &session : activeSessions) {
        QVariantMap sessionMap;
        sessionMap["id"] = session.id;
        sessionMap["display_number"] = session.display_number;
        sessionMap["table_id"] = session.table_id.has_value() ? session.table_id.value() : QVariant();
        sessionMap["order_type"] = session.order_type;
        sessionMap["status"] = session.status;
        sessionMap["subtotal"] = static_cast<double>(session.subtotal) / CURRENCY_SCALE;
        sessionMap["tax"] = static_cast<double>(session.tax) / CURRENCY_SCALE;
        sessionMap["discount"] = static_cast<double>(session.discount) / CURRENCY_SCALE;
        sessionMap["total"] = static_cast<double>(session.total) / CURRENCY_SCALE;
        sessionMap["opened_at"] = session.opened_at.has_value() ? session.opened_at.value() : QVariant();
        sessionMap["closed_at"] = session.closed_at.has_value() ? session.closed_at.value() : QVariant();

        result.append(sessionMap);
    }

    return result;
}

bool CheckoutService::processMembershipPoints(int orderSessionId, const QString &memberPhone, int pointsToRedeem)
{
    if (memberPhone.isEmpty())
        return true;

    if (!m_membershipService.createMember(memberPhone))
        return false;

    QVariantMap member = m_membershipService.getMemberByPhone(memberPhone);
    int memberId = member.value("id").toInt();

    if (memberId <= 0)
        return false;

    auto sessionOpt = m_orderSessionRepo.getById(orderSessionId);
    if (!sessionOpt.has_value())
        return false;

    OrderSession session = sessionOpt.value();

    double discountAmount = 0.0;
    if (pointsToRedeem > 0 && m_membershipService.canRedeem(memberId, pointsToRedeem)) {
        discountAmount = m_membershipService.redeemPoints(memberId, pointsToRedeem);
        qint64 discountMinor = static_cast<qint64>(std::llround(discountAmount * CURRENCY_SCALE));
        session.discount += discountMinor;
        session.total -= discountMinor;
    }

    int earnedPoints = m_membershipService.calculateEarnedPoints(static_cast<double>(session.total) / CURRENCY_SCALE, "total");
    if (earnedPoints > 0) {
        m_membershipService.addTransaction(memberId, earnedPoints, "earn", orderSessionId);
        m_membershipRepo.adjustPoints(memberId, "add", earnedPoints);
    }

    m_orderSessionRepo.update(session);

    return true;
}

bool CheckoutService::recalculateSessionTotals(int orderSessionId)
{
    auto sessionOpt = m_orderSessionRepo.getById(orderSessionId);
    if (!sessionOpt.has_value())
        return false;

    OrderSession session = sessionOpt.value();

    auto orders = m_orderRepo.getOrdersBySessionId(orderSessionId);

    QList<int> orderIds;
    for (const auto &order : orders)
        orderIds.append(order.id);

    auto items = m_orderItemRepo.getOrderItemsByOrderIds(orderIds);

    qint64 subtotal = 0;

    // Sum all items from all orders in minor units (cents)
    for (const auto &item : items) {
        qint64 priceMinor = static_cast<qint64>(std::llround(item.price * CURRENCY_SCALE));
        subtotal += priceMinor * item.quantity;
    }

    // Calculate tax using the TaxCalculationService
    qint64 tax = m_taxCalculationService.calculateTax(subtotal);

    session.subtotal = subtotal;
    session.tax = tax;
    session.total = subtotal + tax;

    m_orderSessionRepo.update(session);

    return true;
}

QVariantList CheckoutService::getCheckoutDetails(const int &orderSessionId)
{
    QVariantList result;

    if (!recalculateSessionTotals(orderSessionId))
        return result;

    auto sessionOpt = m_orderSessionRepo.getById(orderSessionId);
    if (!sessionOpt.has_value())
        return result;

    const auto &session = sessionOpt.value();

    auto orders = m_orderRepo.getOrdersBySessionId(orderSessionId);

    QList<int> orderIds;
    for (const auto &order : orders)
        orderIds.append(order.id);

    auto items = m_orderItemRepo.getOrderItemsByOrderIds(orderIds);

    QMap<int, QVariantList> itemsByOrder;

    for (const auto &item : items) {
        QVariantMap itemMap;
        itemMap["id"] = item.id;
        itemMap["item_id"] = item.item_id;
        itemMap["item_name"] = item.item_name;
        itemMap["quantity"] = item.quantity;
        itemMap["price"] = item.price; // whole units for UI
        itemMap["item_status"] = item.item_status;
        itemMap["notes"] = item.notes;

        itemsByOrder[item.order_id].append(itemMap);
    }

    bool totalsAttached = false;

    for (const auto &order : orders) {
        QVariantMap orderMap;
        orderMap["id"] = order.id;
        orderMap["display_number"] = order.display_number;
        orderMap["status"] = order.status;
        orderMap["notes"] = order.notes;
        orderMap["closed_at"] = order.closed_at.isEmpty() ? QVariant() : order.closed_at;
        orderMap["items"] = itemsByOrder.value(order.id);

        if (!totalsAttached) {
            // Convert minor units to RM for UI
            orderMap["subtotal"] = static_cast<double>(session.subtotal) / CURRENCY_SCALE;
            orderMap["tax"] = static_cast<double>(session.tax) / CURRENCY_SCALE;
            orderMap["discount"] = static_cast<double>(session.discount) / CURRENCY_SCALE;
            orderMap["total"] = static_cast<double>(session.total) / CURRENCY_SCALE;
            totalsAttached = true;
        }

        result.append(orderMap);
    }

    return result;
}

bool CheckoutService::markOrderPaid(const int &orderSessionId, const QString &memberPhone, int pointsToRedeem)
{
    if (!recalculateSessionTotals(orderSessionId))
        return false;

    auto sessionOpt = m_orderSessionRepo.getById(orderSessionId);
    if (!sessionOpt.has_value())
        return false;

    OrderSession session = sessionOpt.value();

    if (!processMembershipPoints(orderSessionId, memberPhone, pointsToRedeem))
        return false;

    m_orderSessionRepo.markAsPaid(orderSessionId);

    if (session.table_id.has_value()) {
        m_tableRepo.setTableState(session.table_id.value(), false);
    }

    return true;
}

bool CheckoutService::printReceipt(int orderSessionId)
{
    if (!recalculateSessionTotals(orderSessionId))
        return false;

    auto sessionOpt = m_orderSessionRepo.getById(orderSessionId);
    if (!sessionOpt.has_value())
        return false;

    const auto &session = sessionOpt.value();

    auto restaurantOpt = m_restaurantRepo.get();
    if (!restaurantOpt.has_value())
        return false;

    auto printerOpt = m_printerRepo.get();
    if (!printerOpt.has_value())
        return false;

    ReceiptData data;
    data.storeName = restaurantOpt->name;
    data.address = restaurantOpt->address;
    data.phone = restaurantOpt->phone_number.value_or("");
    data.email = restaurantOpt->email.value_or("");
    data.website = restaurantOpt->website.value_or("");
    data.subtotal = static_cast<double>(session.subtotal) / CURRENCY_SCALE;
    data.tax = static_cast<double>(session.tax) / CURRENCY_SCALE;
    data.total = static_cast<double>(session.total) / CURRENCY_SCALE;

    QString formattedText = m_formatter.format(data, printerOpt->char_per_line);

    EscPosBuilder builder;
    builder.initialize();
    builder.addText(formattedText);
    builder.cut(printerOpt->cut_mode);

    return m_printerService.print(
        *printerOpt->ip_address,
        static_cast<quint16>(*printerOpt->port),
        builder.data());
}
