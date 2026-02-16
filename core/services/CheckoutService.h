#ifndef CHECKOUTSERVICE_H
#define CHECKOUTSERVICE_H

#include <QVariantList>
#include <QObject>
#include <QString>
#include <QVariantMap>
#include "../data/OrderSessionRepository.h"
#include "../data/OrderRepository.h"
#include "../data/OrderItemRepository.h"
#include "../data/RestaurantRepository.h"
#include "../data/PrinterSettingRepository.h"
#include "../printing/ReceiptFormatter.h"
#include "../printing/NetworkPrinterService.h"


class CheckoutService : public QObject
{
    Q_OBJECT

public:
    explicit CheckoutService(OrderSessionRepository &orderSessionRepo,
                             OrderRepository &orderRepo,
                             OrderItemRepository &orderItemRepo,
                             RestaurantRepository &restaurantRepo,
                             PrinterSettingRepository &printerRepo,
                             ReceiptFormatter &formatter,
                             NetworkPrinterService &printerService);

    Q_INVOKABLE QVariantList getActiveOrdersForCheckout() const;
    Q_INVOKABLE bool markOrderPaid(const int &orderSessionId);
    Q_INVOKABLE QVariantList getCheckoutDetails(const int &orderSessionId);

    Q_INVOKABLE bool printReceipt(int orderSessionId);

private:
    OrderSessionRepository &m_orderSessionRepo;
    OrderRepository &m_orderRepo;
    OrderItemRepository &m_orderItemRepo;
    RestaurantRepository &m_restaurantRepo;
    PrinterSettingRepository &m_printerRepo;
    ReceiptFormatter &m_formatter;
    NetworkPrinterService &m_printerService;
};

#endif // CHECKOUTSERVICE_H
