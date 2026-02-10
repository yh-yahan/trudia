#ifndef KITCHENORDERSERVICE_H
#define KITCHENORDERSERVICE_H

#include <QVariantList>
#include <QObject>
#include <QString>
#include <QVariantMap>
#include "../data/OrderSessionRepository.h"
#include "../data/OrderRepository.h"
#include "../data/OrderItemRepository.h"

class KitchenOrderService : public QObject
{
    Q_OBJECT

public:
    explicit KitchenOrderService(OrderSessionRepository &orderSessionRepo,
                                 OrderRepository &orderRepo,
                                 OrderItemRepository &orderItemRepo);

    Q_INVOKABLE QVariantList getOrdersByStatus(const QString &status) const;
    Q_INVOKABLE bool markState(const int &orderId, const QString state);

private:
    OrderSessionRepository &m_orderSessionRepo;
    OrderRepository &m_orderRepo;
    OrderItemRepository &m_orderItemRepo;
};

#endif // KITCHENORDERSERVICE_H
