#ifndef ORDERITEMREPOSITORY_H
#define ORDERITEMREPOSITORY_H

#include <QString>
#include <QSqlDatabase>
#include "../domain/OrderItem.h"

class OrderItemRepository
{
public:
    explicit OrderItemRepository(QSqlDatabase db);

    std::vector<OrderItem> getAllOrderItems();
    std::optional<OrderItem> getOrderItemById(int orderItemId);
    std::vector<OrderItem> getOrderItemsByOrderId(int orderId);
    std::vector<OrderItem> getOrderItemsByOrderIds(const QList<int> &orderIds);
    void markItemsByOrderId(int orderId, const QString &status);
    void create(const OrderItem &orderItem);
    void update(const OrderItem &orderItem);
    void remove(const OrderItem &orderItem);
    void removeByOrderId(int orderId);

private:
    QSqlDatabase m_db;
};

#endif // ORDERITEMREPOSITORY_H
