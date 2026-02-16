#include "CheckoutService.h"

#include <QDateTime>
#include "../printing/EscPosBuilder.h"

CheckoutService::CheckoutService(OrderSessionRepository &orderSessionRepo, OrderRepository &orderRepo,
                            OrderItemRepository &orderItemRepo,
                            RestaurantRepository &restaurantRepo,
                            PrinterSettingRepository &printerRepo,
                            ReceiptFormatter &formatter,
                            NetworkPrinterService &printerService)
    : m_orderSessionRepo(orderSessionRepo),
      m_orderRepo(orderRepo),
      m_orderItemRepo(orderItemRepo),
      m_restaurantRepo(restaurantRepo),
      m_printerRepo(printerRepo),
      m_formatter(formatter),
      m_printerService(printerService){}

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
        sessionMap["subtotal"] = session.subtotal;
        sessionMap["tax"] = session.tax;
        sessionMap["discount"] = session.discount;
        sessionMap["total"] = session.total;
        sessionMap["opened_at"] = session.opened_at.has_value() ? session.opened_at.value() : QVariant();
        sessionMap["closed_at"] = session.closed_at.has_value() ? session.closed_at.value() : QVariant();

        result.append(sessionMap);
    }

    return result;
}

bool CheckoutService::markOrderPaid(const int &orderSessionId)
{
    auto sessionOpt = m_orderSessionRepo.getById(orderSessionId);
    if (!sessionOpt.has_value()) {
        qWarning() << "Order session not found for id:" << orderSessionId;
        return false;
    }

    OrderSession session = sessionOpt.value();

    session.status = "paid";

    session.closed_at = QDateTime::currentDateTime().toString(Qt::ISODate);

    m_orderSessionRepo.update(session);

    return true;
}

QVariantList CheckoutService::getCheckoutDetails(const int &orderSessionId)
{
    QVariantList result;

    auto sessionOpt = m_orderSessionRepo.getById(orderSessionId);
    if (!sessionOpt.has_value()) {
        qWarning() << "Order session not found for id:" << orderSessionId;
        return result;
    }

    const auto &session = sessionOpt.value();

    auto orders = m_orderRepo.getOrdersBySessionId(orderSessionId);

    QList<int> orderIds;
    for (const auto &order : orders) {
        orderIds.append(order.id);
    }
    auto items = m_orderItemRepo.getOrderItemsByOrderIds(orderIds);

    QMap<int, QVariantList> itemsByOrder;
    for (const auto &item : items) {
        QVariantMap itemMap;
        itemMap["id"] = item.id;
        itemMap["item_id"] = item.item_id;
        itemMap["item_name"] = item.item_name;
        itemMap["quantity"] = item.quantity;
        itemMap["price"] = item.price;
        itemMap["item_status"] = item.item_status;
        itemMap["notes"] = item.notes;

        itemsByOrder[item.order_id].append(itemMap);
    }

    for (const auto &order : orders) {
        QVariantMap orderMap;
        orderMap["id"] = order.id;
        orderMap["display_number"] = order.display_number;
        orderMap["status"] = order.status;
        orderMap["notes"] = order.notes;
        orderMap["closed_at"] = order.closed_at.isEmpty() ? QVariant() : order.closed_at;
        orderMap["items"] = itemsByOrder.value(order.id);
        orderMap["subtotal"] = session.subtotal;
        orderMap["tax"] = session.tax;
        orderMap["discount"] = session.discount;
        orderMap["total"] = session.total;

        result.append(orderMap);
    }

    return result;
}

bool CheckoutService::printReceipt(int orderSessionId)
{
    auto sessionOpt = m_orderSessionRepo.getById(orderSessionId);
    if (!sessionOpt.has_value()) return false;
    const auto &session = sessionOpt.value();

    auto restaurantOpt = m_restaurantRepo.get();
    if (!restaurantOpt.has_value()) return false;

    auto printerOpt = m_printerRepo.get();
    if (!printerOpt.has_value()) return false;

    ReceiptData data;
    data.storeName = restaurantOpt->name;
    data.address = restaurantOpt->address;
    data.phone = restaurantOpt->phone_number.value_or("");
    data.email = restaurantOpt->email.value_or("");
    data.website = restaurantOpt->website.value_or("");
    data.subtotal = session.subtotal;
    data.tax = session.tax;
    data.total = session.total;

    QString formattedText = m_formatter.format(data, printerOpt->char_per_line);

    EscPosBuilder builder;
    builder.initialize();
    builder.addText(formattedText);

    builder.cut(printerOpt->cut_mode);

    return m_printerService.print(*printerOpt->ip_address,
                                  static_cast<quint16>(*printerOpt->port),
                                  builder.data());
}
