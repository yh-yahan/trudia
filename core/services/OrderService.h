#ifndef ORDERSERVICE_H
#define ORDERSERVICE_H

#include <QObject>
#include <QString>
#include "../data/OrderSessionRepository.h"
#include "../data/OrderRepository.h"
#include "../data/OrderItemRepository.h"
#include "../data/TableRepository.h"
#include "../data/MenuRepository.h"
#include "../data/PrinterRepository.h"
#include "./TaxCalculationService.h"
#include "./SettingService.h"
#include "../printing/KitchenTicketBuilder.h"
#include "../printing/WindowsPrinterService.h"

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
                          PrinterRepository &printerRepo,
                          TaxCalculationService &taxService,
                          KitchenTicketBuilder &kitchenTicketBuilder,
                          SettingService &settingService,
                          WindowsPrinterService &windowsPrinterService);

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
    PrinterRepository &m_printerRepo;
    TaxCalculationService &m_taxService;
    KitchenTicketBuilder &m_kitchenTicketBuilder;
    SettingService &m_settingService;
    WindowsPrinterService &m_windowsPrinterService;
    int generateOrderSessionDisplayNumber();
    int generateOrderDisplayNumber();
};

#endif // ORDERSERVICE_H
