#ifndef ORDERSERVICE_H
#define ORDERSERVICE_H

#include <QObject>
#include <QString>
#include "../data/OrderSessionRepository.h"
#include "../data/OrderRepository.h"
#include "../data/OrderItemRepository.h"
#include "../data/TableRepository.h"
#include "../data/MenuRepository.h"
#include "./TaxCalculationService.h"

class OrderService : public QObject
{
    Q_OBJECT
public:
    explicit OrderService(OrderSessionRepository &orderSessionRepo,
                          OrderRepository &orderRepo,
                          OrderItemRepository &orderItemRepo,
                          TableRepository &tableRepo,
                          MenuRepository &menuRepo,
                          TaxCalculationService &taxService);

    Q_INVOKABLE int createOrder(
        const QString &orderType,
        const QVariantList &items,
        const QVariantMap &options = {}
    );
    
    Q_INVOKABLE QVariantList getOpenOrders();
    Q_INVOKABLE QVariantList getOrderItems(int orderId);
    Q_INVOKABLE int updateOrder(
        int orderId,
        const QString &orderType,
        const QVariantList &items,
        const QVariantMap &options
    );

private:
    OrderSessionRepository &m_orderSessionRepo;
    OrderRepository &m_orderRepo;
    OrderItemRepository &m_orderItemRepo;
    TableRepository &m_tableRepo;
    MenuRepository &m_menuRepo;
    TaxCalculationService &m_taxService;
    int generateOrderSessionDisplayNumber();
    int generateOrderDisplayNumber();
};

#endif // ORDERSERVICE_H
