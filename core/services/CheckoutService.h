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
#include "../data/PrinterRepository.h"
#include "../data/TaxSettingsRepository.h"
#include "../data/TableRepository.h"
#include "../data/MembershipRepository.h"
#include "../data/MembershipTransactionRepository.h"
#include "../data/TaxSettingsRepository.h"
#include "../data/AppStateRepository.h"
#include "../printing/ReceiptBuilder.h"
#include "../printing/WindowsPrinterService.h"
#include "./TaxCalculationService.h"
#include "./MembershipService.h"
#include "./SettingService.h"
#include "./TableService.h"
#include "./ReservationService.h"

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
                             PrinterRepository &printerRepo,
                             TableRepository &tableRepo,
                             MembershipRepository &membershipRepo,
                             MembershipTransactionRepository &membershipTransactionRepo,
                             TaxSettingsRepository &taxSettingsRepository,
                             AppStateRepository &appStateRepo,
                             ReceiptBuilder &receiptBuilder,
                             WindowsPrinterService &windowsPrinterService,
                             TaxCalculationService &taxCalculationService,
                             MembershipService &membershipService,
                             SettingService &settingService,
                             TableService &tableService,
                             ReservationService &reservationService);

    Q_INVOKABLE QVariantList loadActiveCheckoutSessions();
    Q_INVOKABLE bool processMembershipPoints(int orderSessionId, const QString &memberPhone, int pointsToRedeem);
    Q_INVOKABLE bool markOrderPaid(const int &orderSessionId, const QString &memberPhone, int pointsToRedeem);
    bool recalculateSessionTotals(int orderSessionId);
    Q_INVOKABLE QVariantList loadCheckoutDetails(const int &orderSessionId);
    Q_INVOKABLE bool printReceipt(int orderSessionId);
    Q_INVOKABLE QVariantList getRecentPaidOrders() const;

private:
    OrderSessionRepository &m_orderSessionRepo;
    OrderRepository &m_orderRepo;
    OrderItemRepository &m_orderItemRepo;
    RestaurantRepository &m_restaurantRepo;
    PrinterRepository &m_printerRepo;
    MembershipRepository &m_membershipRepo;
    MembershipTransactionRepository &m_membershipTransactionRepository;
    TaxSettingsRepository &m_taxSettingsRepo;
    AppStateRepository &m_appStateRepo;
    ReceiptBuilder &m_receiptBuilder;
    WindowsPrinterService &m_windowsPrinterService;
    TaxCalculationService &m_taxCalculationService;
    SettingService &m_settingService;
    TableRepository &m_tableRepo;
    MembershipService &m_membershipService;
    TableService &m_tableService;
    ReservationService &m_reservationService;

    bool assignReceiptNumber(OrderSession &session);
};

#endif // CHECKOUTSERVICE_H
