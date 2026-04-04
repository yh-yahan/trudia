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
#include "./SettingService.h"
#include "../printing/KitchenPrinterService.h"
#include "../printing/KitchenTicketBuilder.h"

class OrderService : public QObject
{
    Q_OBJECT

signals:
    void orderCreated(int orderId);
    void orderUpdated(int orderId);

public:
    explicit OrderService(OrderSessionRepository &orderSessionRepo,
                          OrderRepository &orderRepo,
                          OrderItemRepository &orderItemRepo,
                          TableRepository &tableRepo,
                          MenuRepository &menuRepo,
                          TaxCalculationService &taxService,
                          KitchenPrinterService &kitchenPrinter,
                          KitchenTicketBuilder &kitchenTicketBuilder,
                          SettingService &settingService);

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

    Q_INVOKABLE bool printKitchenTicket(int orderId);

private:
    OrderSessionRepository &m_orderSessionRepo;
    OrderRepository &m_orderRepo;
    OrderItemRepository &m_orderItemRepo;
    TableRepository &m_tableRepo;
    MenuRepository &m_menuRepo;
    TaxCalculationService &m_taxService;
    KitchenPrinterService &m_kitchenPrinter;
    KitchenTicketBuilder &m_kitchenTicketBuilder;
    SettingService &m_settingService;
    int generateOrderSessionDisplayNumber();
    int generateOrderDisplayNumber();
};

#endif // ORDERSERVICE_H
