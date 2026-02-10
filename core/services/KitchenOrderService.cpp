#include "KitchenOrderService.h"

#include <QDate>

KitchenOrderService::KitchenOrderService(OrderSessionRepository &orderSessionRepo,
                                         OrderRepository &orderRepo,
                                         OrderItemRepository &orderItemRepo)
    : m_orderSessionRepo(orderSessionRepo), m_orderRepo(orderRepo), m_orderItemRepo(orderItemRepo) {}

QVariantList KitchenOrderService::getOrdersByStatus(const QString &status) const
{
    QVariantList result;

    const auto orders = m_orderRepo.getOrdersByStatus(status);
    if (orders.empty()) return result;

    QList<int> orderIds;
    for (const auto &order : orders) {
        orderIds.append(order.id);
    }

    std::vector<OrderItem> allItems = m_orderItemRepo.getOrderItemsByOrderIds(orderIds);

    QMap<int, QVariantList> itemsByOrder;
    for (const auto &item : allItems) {
        QVariantMap itemMap;
        itemMap["id"] = item.id;
        itemMap["item_name"] = item.item_name;
        itemMap["quantity"] = item.quantity;
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

        orderMap["items"] = itemsByOrder.value(order.id);

        auto sessionOpt = m_orderSessionRepo.getById(order.order_session_id);
        if (sessionOpt.has_value()) {
            const auto &session = sessionOpt.value();
            orderMap["table_id"] = session.table_id.has_value()
                                       ? QVariant(session.table_id.value())
                                       : QVariant();
            orderMap["order_type"] = session.order_type;
        }

        result.append(orderMap);
    }

    return result;
}

bool KitchenOrderService::markState(const int &orderId, const QString state)
{
    auto orderOpt = m_orderRepo.getOrderById(orderId);
    if (!orderOpt.has_value()) {
        qWarning() << "markState failed: order not found, id=" << orderId;
        return false;
    }

    Order order = orderOpt.value();

    order.status = state;

    if (state == "served") {
        order.closed_at = QDateTime::currentDateTime().toString(Qt::ISODate);
    }

    m_orderRepo.update(order);

    return true;
}
