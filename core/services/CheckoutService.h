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
#include "../data/ReceiptSnapshotRepository.h"
#include "../data/RegionalSettingsRepository.h"
#include "../printing/ReceiptBuilder.h"
#include "../printing/WindowsPrinterService.h"
#include "./TaxCalculationService.h"
#include "./MembershipService.h"
#include "./SettingService.h"
#include "./TableService.h"
#include "./ReservationService.h"
#include "./AuthService.h"

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
                             ReceiptSnapshotRepository &receiptSnapshotRepo,
                             RegionalSettingsRepository &regionalSettingsRepo,
                             ReceiptBuilder &receiptBuilder,
                             WindowsPrinterService &windowsPrinterService,
                             TaxCalculationService &taxCalculationService,
                             MembershipService &membershipService,
                             SettingService &settingService,
                             TableService &tableService,
                             ReservationService &reservationService,
                             AuthService &authService);

    Q_INVOKABLE QVariantList loadActiveCheckoutSessions();
    Q_INVOKABLE bool markOrderPaid(const int &orderSessionId, const QString &memberPhone, int pointsToRedeem);
    bool recalculateSessionTotals(int orderSessionId);
    Q_INVOKABLE QVariantList loadCheckoutDetails(const int &orderSessionId);
    Q_INVOKABLE bool printReceipt(int orderSessionId, const bool &isReprint);
    Q_INVOKABLE QVariantList getRecentPaidOrders() const;
    Q_INVOKABLE QVariantMap loadPaidOrderDetails(const int &orderSessionId);

private:
    OrderSessionRepository &m_orderSessionRepo;
    OrderRepository &m_orderRepo;
    OrderItemRepository &m_orderItemRepo;
    RestaurantRepository &m_restaurantRepo;
    PrinterRepository &m_printerRepo;
    MembershipRepository &m_membershipRepo;
    MembershipTransactionRepository &m_membershipTransactionRepo;
    TaxSettingsRepository &m_taxSettingsRepo;
    AppStateRepository &m_appStateRepo;
    ReceiptSnapshotRepository &m_receiptSnapshotRepo;
    RegionalSettingsRepository &m_regionalSettingsRepo;
    ReceiptBuilder &m_receiptBuilder;
    WindowsPrinterService &m_windowsPrinterService;
    TaxCalculationService &m_taxCalculationService;
    SettingService &m_settingService;
    TableRepository &m_tableRepo;
    MembershipService &m_membershipService;
    TableService &m_tableService;
    ReservationService &m_reservationService;
    AuthService &m_authService;

    bool assignReceiptNumber(OrderSession &session);
    bool applyMembershipToSession(OrderSession &session, const QString &memberPhone, int pointsToRedeem);
    void markOrdersServed(int orderSessionId);
    bool createReceiptSnapshot(const OrderSession &session);
    void freeTable(const OrderSession &session);
};

#endif // CHECKOUTSERVICE_H
