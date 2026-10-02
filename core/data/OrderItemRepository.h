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
    bool markItemsByOrderId(int orderId, const QString &status);
    int create(OrderItem &orderItem);
    bool update(const OrderItem &orderItem);
    bool remove(int orderItemId);
    void removeByOrderId(int orderId);

private:
    QSqlDatabase m_db;
};

#endif // ORDERITEMREPOSITORY_H
