#ifndef ORDERREPOSITORY_H
#define ORDERREPOSITORY_H

#include <QString>
#include <QSqlDatabase>
#include <optional>
#include "../domain/Order.h"

class OrderRepository
{
public:
    explicit OrderRepository(QSqlDatabase db);

    std::optional<Order> getOrderById(int orderId);
    int getMaxDisplayNumberForDate(const QString &date);
    int create(const Order &order);
    void update(const Order &order);
    void remove(const Order &order);

private:
    QSqlDatabase m_db;
};

#endif // ORDERREPOSITORY_H
