#include "OrderService.h"

OrderService::OrderService(OrderRepository &orderRepo,
                           OrderItemRepository &orderItemRepo,
                           TableRepository &tableRepo)
    : m_orderRepo(orderRepo), m_orderItemRepo(orderItemRepo), m_tableRepo(tableRepo) {}

int OrderService::createOrder(
    const QString &orderType,
    const QVariantList &items,
    const QVariantMap &options)
{
    if (items.isEmpty()) {
        qWarning() << "createOrder failed: empty order";
        return -1;
    }

    Order order;
    order.order_type = orderType;
    order.status = "open";
    order.subtotal = 0.0;
    order.tax = 0.0;
    order.total = 0.0;
    order.notes = options.value("notes").toString();

    if (orderType == "dine_in") {
        order.table_id = options.value("tableId").toInt();
    }

    int orderId = m_orderRepo.create(order);

    double subtotal = 0.0;

    for (const QVariant &v : items) {
        QVariantMap m = v.toMap();

        OrderItem item;
        item.order_id = orderId;
        item.item_id = m["menuItemId"].toInt();
        item.item_name = m["name"].toString();
        item.quantity = m["qty"].toInt();
        item.price = m["price"].toDouble();
        item.notes = m["notes"].toString();
        item.item_status = "pending";

        subtotal += item.quantity * item.price;
        m_orderItemRepo.create(item);
    }

    order.subtotal = subtotal;
    order.tax = subtotal * 0.0;
    order.total = subtotal + order.tax;

    m_orderRepo.update(order);

    if (orderType == "dine_in") {
        auto tableOpt = m_tableRepo.getTableById(order.table_id.value());
        if (tableOpt.has_value()) {
            m_tableRepo.setTableState(order.table_id.value(), true);
        }
    }

    return orderId;
}
