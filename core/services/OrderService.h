#ifndef ORDERSERVICE_H
#define ORDERSERVICE_H

#include <QObject>
#include <QString>
#include "../data/OrderRepository.h"
#include "../data/OrderItemRepository.h"
#include "../data/TableRepository.h"

class OrderService : public QObject
{
    Q_OBJECT
public:
    explicit OrderService(OrderRepository &orderRepo, OrderItemRepository &orderItemRepo,
                          TableRepository &tableRepo);

    Q_INVOKABLE int createOrder(
        const QString &orderType,
        const QVariantList &items,
        const QVariantMap &options = {}
        );

    // bool finalizeOrder(int orderId);
    // printKitchenTicket
    // printReceipt

    // bool markPreparing(int orderId);
    // bool markReady(int orderId);
    // bool markCompleted(int orderId);
    // bool cancelOrder(int orderId, const QString& reason = "");

private:
    OrderRepository &m_orderRepo;
    OrderItemRepository &m_orderItemRepo;
    TableRepository &m_tableRepo;
};

#endif // ORDERSERVICE_H
