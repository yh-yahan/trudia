#ifndef ORDERITEMMODIFIERREPOSITORY_H
#define ORDERITEMMODIFIERREPOSITORY_H

#include <QString>
#include <QSqlDatabase>
#include "../domain/OrderItemModifier.h"

class OrderItemModifierRepository
{
public:
    explicit OrderItemModifierRepository(QSqlDatabase db);

    std::vector<OrderItemModifier> getAll();
    std::optional<OrderItemModifier> getById(int id);
    std::vector<OrderItemModifier> getByOrderItemId(int orderItemId);

    void create(const OrderItemModifier &modifier);
    void update(const OrderItemModifier &modifier);
    void remove(const OrderItemModifier &modifier);

private:
    QSqlDatabase m_db;
};

#endif // ORDERITEMMODIFIERREPOSITORY_H
