#include "CheckoutService.h"

#include <cmath>

constexpr qint64 CURRENCY_SCALE = 100; // cents

CheckoutService::CheckoutService(OrderSessionRepository &orderSessionRepo,
                                 OrderRepository &orderRepo,
                                 OrderItemRepository &orderItemRepo,
                                 RestaurantRepository &restaurantRepo,
                                 PrinterSettingRepository &printerRepo,
                                 TableRepository &tableRepo,
                                 MembershipRepository &membershipRepo,
                                 MembershipTransactionRepository &membershipTransactionRepo,
                                 ReceiptBuilder &receiptBuilder,
                                 NetworkPrinterService &networkPrinterService,
                                 USBPrinterService &usbPrinterService,
                                 TaxCalculationService &taxCalculationService,
                                 MembershipService &membershipService,
                                 SettingService &settingService)
    : m_orderSessionRepo(orderSessionRepo),
      m_orderRepo(orderRepo),
      m_orderItemRepo(orderItemRepo),
      m_restaurantRepo(restaurantRepo),
      m_printerRepo(printerRepo),
      m_membershipRepo(membershipRepo),
      m_membershipTransactionRepository(membershipTransactionRepo),
      m_receiptBuilder(receiptBuilder),
      m_networkPrinterService(networkPrinterService),
      m_usbPrinterService(usbPrinterService),
      m_taxCalculationService(taxCalculationService),
      m_tableRepo(tableRepo),
      m_membershipService(membershipService),
      m_settingService(settingService) {}

QVariantList CheckoutService::getActiveOrdersForCheckout() const
{
    QVariantList result;

    auto activeSessions = m_orderSessionRepo.getAllActiveOrderSessions();

    auto tables = m_tableRepo.getAllTables();
    QMap<int, QString> tableMap;

    for (const auto &table : tables)
    {
        tableMap[table.id] = table.table_number;
    }

    for (const auto &session : activeSessions)
    {
        QVariantMap sessionMap;
        sessionMap["id"] = session.id;
        sessionMap["display_number"] = session.display_number;

        if (session.table_id.has_value())
        {
            int tableId = session.table_id.value();
            sessionMap["table_number"] = tableMap.value(tableId);
        }
        else
        {
            sessionMap["table_number"] = QVariant();
        }

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

    if (pointsToRedeem > 0)
    {
        double discountRM =
            m_membershipService.redeemPoints(
                memberId,
                pointsToRedeem,
                session.total);

        qint64 discountCents =
            static_cast<qint64>(std::llround(discountRM * CURRENCY_SCALE));

        if (discountCents > 0)
        {
            session.discount += discountCents;
            session.total -= discountCents;
        }
    }

    int earnedPoints =
        m_membershipService.calculateEarnedPoints(session.subtotal, session.total);

    if (earnedPoints > 0)
    {
        m_membershipService.addTransaction(
            memberId, earnedPoints, "earn", orderSessionId);

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

    for (const auto &item : items)
    {
        subtotal += item.price * item.quantity;
    }

    qint64 tax = m_taxCalculationService.calculateTax(subtotal);

    session.subtotal = subtotal;
    session.tax = tax;

    session.total = subtotal + tax - session.discount;

    if (session.total < 0)
        session.total = 0;

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

    for (const auto &item : items)
    {
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

    for (const auto &order : orders)
    {
        QVariantMap orderMap;
        orderMap["id"] = order.id;
        orderMap["display_number"] = order.display_number;
        orderMap["status"] = order.status;
        orderMap["notes"] = order.notes;
        orderMap["closed_at"] = order.closed_at.isEmpty() ? QVariant() : order.closed_at;
        orderMap["items"] = itemsByOrder.value(order.id);

        if (!totalsAttached)
        {
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

    if (session.table_id.has_value())
    {
        m_tableRepo.setTableState(session.table_id.value(), false);
    }

    return true;
}

bool CheckoutService::printReceipt(int orderSessionId)
{
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
    data.discount = static_cast<double>(session.discount) / CURRENCY_SCALE;

    auto orders = m_orderRepo.getOrdersBySessionId(orderSessionId);

    QList<int> orderIds;
    for (const auto &order : orders)
        orderIds.append(order.id);

    auto items = m_orderItemRepo.getOrderItemsByOrderIds(orderIds);

    struct GroupKey
    {
        QString name;
        qint64 price;

        bool operator<(const GroupKey &other) const
        {
            if (name != other.name)
                return name < other.name;
            return price < other.price;
        }
    };

    QMap<GroupKey, int> grouped;

    for (const auto &item : items)
    {
        GroupKey key{
            item.item_name,
            static_cast<qint64>(item.price)
        };

        grouped[key] += item.quantity;
    }

    for (auto it = grouped.begin(); it != grouped.end(); ++it)
    {
        ReceiptItem rItem;
        rItem.name = it.key().name;
        rItem.quantity = it.value();
        rItem.price = static_cast<double>(it.key().price) / CURRENCY_SCALE;

        data.items.append(rItem);
    }

    data.membershipEnabled = m_settingService.membershipEnabled();

    if (data.membershipEnabled)
    {
        int membershipId =
            m_membershipTransactionRepository.getMembershipIdBySession(orderSessionId);

        if (membershipId > 0)
        {
            auto membership =
                m_membershipRepo.getMembershipById(membershipId);

            data.memberPhone = membership.phone_number;
            data.pointsBalance = membership.total_points;

            data.pointsRedeemed =
                m_membershipTransactionRepository.getRedeemedPoints(orderSessionId);

            data.pointsEarned =
                m_membershipTransactionRepository.getEarnedPoints(orderSessionId);
        }
    }

    QByteArray payload = m_receiptBuilder.build(data);

    if (printerOpt->connection_type == "USB")
    {
        return m_usbPrinterService.print(
            *printerOpt->com_port,
            payload);
    }
    else if (printerOpt->connection_type == "Network")
    {
        return m_networkPrinterService.print(
            *printerOpt->ip_address,
            static_cast<quint16>(*printerOpt->port),
            payload);
    }

    return false;
}

QVariantList CheckoutService::getRecentPaidOrders() const
{
    QVariantList result;

    auto sessions = m_orderSessionRepo.getRecentPaidSessions(20);

    for (const auto &session : sessions)
    {
        QVariantMap map;

        map["id"] = session.id;
        map["display_number"] = session.display_number;
        map["total"] = session.total / 100;

        result.append(map);
    }

    return result;
}
