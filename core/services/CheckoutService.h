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
#include "../data/TaxSettingsRepository.h"
#include "../data/TableRepository.h"
#include "../data/MembershipRepository.h"
#include "../printing/ReceiptFormatter.h"
#include "../printing/NetworkPrinterService.h"
#include "../printing/USBPrinterService.h"
#include "./TaxCalculationService.h"
#include "./MembershipService.h"

struct TaxComputationResult {
    double subtotal = 0.0;
    double taxTotal = 0.0;
    double grandTotal = 0.0;
};

class CheckoutService : public QObject
{
    Q_OBJECT

public:
    explicit CheckoutService(OrderSessionRepository &orderSessionRepo,
                             OrderRepository &orderRepo,
                             OrderItemRepository &orderItemRepo,
                             RestaurantRepository &restaurantRepo,
                             PrinterSettingRepository &printerRepo,
                             TableRepository &tableRepo,
                             MembershipRepository &membershipRepo,
                             ReceiptFormatter &formatter,
                             NetworkPrinterService &networkPrinterService,
                             USBPrinterService &usbPrinterService,
                             TaxCalculationService &taxCalculationService,
                             MembershipService &membershipService);

    Q_INVOKABLE QVariantList getActiveOrdersForCheckout() const;
    Q_INVOKABLE bool processMembershipPoints(int orderSessionId, const QString &memberPhone, int pointsToRedeem);
    Q_INVOKABLE bool markOrderPaid(const int &orderSessionId, const QString &memberPhone, int pointsToRedeem);
    bool recalculateSessionTotals(int orderSessionId);
    Q_INVOKABLE QVariantList getCheckoutDetails(const int &orderSessionId);
    Q_INVOKABLE bool printReceipt(int orderSessionId);
    Q_INVOKABLE QVariantList getRecentPaidOrders() const;

private:
    OrderSessionRepository &m_orderSessionRepo;
    OrderRepository &m_orderRepo;
    OrderItemRepository &m_orderItemRepo;
    RestaurantRepository &m_restaurantRepo;
    PrinterSettingRepository &m_printerRepo;
    MembershipRepository &m_membershipRepo;
    ReceiptFormatter &m_formatter;
    NetworkPrinterService &m_networkPrinterService;
    USBPrinterService &m_usbPrinterService;
    TaxCalculationService &m_taxCalculationService;
    TableRepository &m_tableRepo;
    MembershipService &m_membershipService;
};

#endif // CHECKOUTSERVICE_H
