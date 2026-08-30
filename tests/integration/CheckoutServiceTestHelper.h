#ifndef CHECKOUTSERVICETESTHELPER_H
#define CHECKOUTSERVICETESTHELPER_H

#include "../../core/database/DatabaseManager.h"
#include "../../core/services/CheckoutService.h"
#include "../../core/constants/TableStatus.h"
#include "../../core/constants/ReservationStatus.h"
#include "../../core/data/MenuRepository.h"
#include "../../core/data/CategoryRepository.h"
#include "../../core/data/OrderSessionRepository.h"
#include "../../core/data/OrderRepository.h"
#include "../../core/data/OrderItemRepository.h"
#include "../../core/data/TableRepository.h"
#include "../../core/data/TaxSettingsRepository.h"
#include "../../core/data/MembershipRepository.h"
#include "../../core/data/MembershipSettingsRepository.h"
#include "../../core/data/MembershipTransactionRepository.h"
#include "../../core/data/RestaurantRepository.h"
#include "../../core/data/ReceiptSnapshotRepository.h"
#include "../../core/data/AppStateRepository.h"
#include "../../core/data/PrinterRepository.h"
#include "../../core/data/RegionalSettingsRepository.h"
#include "../../core/data/UserRepository.h"
#include "../../core/data/KitchenSettingsRepository.h"
#include "../../core/data/TableSettingsRepository.h"
#include "../../core/data/ReservationRepository.h"
#include "../../core/data/PaymentRepository.h"
#include "../../core/services/MembershipService.h"
#include "../../core/services/SettingService.h"
#include "../../core/services/TableService.h"
#include "../../core/services/ReservationService.h"
#include "../../core/services/TaxCalculationService.h"
#include "../../core/services/AuthService.h"
#include "../../core/services/CurrencyService.h"
#include "../../core/services/PaymentService.h"
#include "../../core/printing/ReceiptBuilder.h"
#include "../../core/printing/WindowsPrinterService.h"

class CheckoutServiceTestHelper
{
public:
    CheckoutServiceTestHelper();
    ~CheckoutServiceTestHelper();

    CheckoutService &checkoutService() { return *m_checkoutService; }

    PaymentService &paymentService() { return *m_paymentService; }

    // repositories
    OrderSessionRepository &orderSessionRepo() { return *m_orderSessionRepo; }
    OrderRepository &orderRepo() { return *m_orderRepo; }
    OrderItemRepository &orderItemRepo() { return *m_orderItemRepo; }
    TableRepository &tableRepo() { return *m_tableRepo; }
    TaxSettingsRepository &taxSettingsRepo() { return *m_taxSettingsRepo; }
    ReceiptSnapshotRepository &receiptSnapshotRepo() { return *m_receiptSnapshotRepo; }
    AppStateRepository &appStateRepo() { return *m_appStateRepo; }

    DatabaseManager &dbManager() { return m_dbManager; }

    int createCategory(const QString &name = "Test Category");
    int createMenuItem(const QString &name, qint64 price, bool isTaxable);
    void addOrderItem(int orderId, int menuId, int quantity);
    
    int createTestSession(int displayNumber = 1001, 
                          const QString& orderType = "dine_in",
                          qint64 discount = 0);

    int createOrderForSession(int sessionId, int displayNumber = 1);
    void setTaxSettings(bool enabled = true, qint64 rate = 100);

    int createSessionWithItems(int displayNumber = 1001,
                               qint64 discount = 0,
                               const QList<QVariantMap> &items = {});

    void createRestaurant(
        const QString &name = "Test Restaurant",
        const QString &address = "123 Test Street",
        const QString &phone = "0123456789",
        const QString &email = "test@example.com",
        const QString &website = "example.com");

    void setupTestCashier(
        const QString &username = "cashier",
        const QString &password = "password",
        const QString &role = "admin");

    void setReceiptCounter(int year, int counter);

    int createTable(
        const QString &name = "A1",
        const QString &status = TableStatus::Occupied);

    void assignTableToSession(int sessionId, int tableId);

    void enableMembership(
        bool enabled = true,
        int earnPoints = 1,
        int earnSpend = 100,
        QString earnOn = "total",
        int redeemPoints = 100,
        int redeemValue = 100);

    int createMember(const QString &phone = "0123456789", int points = 500);

    int createReservation(
        int tableId,
        const QString &customer = "John",
        const QString &status = ReservationStatus::Seated);

private:
    DatabaseManager m_dbManager;

    // repositories
    std::unique_ptr<CategoryRepository> m_categoryRepo;
    std::unique_ptr<MenuRepository> m_menuRepo;
    std::unique_ptr<OrderSessionRepository> m_orderSessionRepo;
    std::unique_ptr<OrderRepository> m_orderRepo;
    std::unique_ptr<OrderItemRepository> m_orderItemRepo;
    std::unique_ptr<TableRepository> m_tableRepo;
    std::unique_ptr<TaxSettingsRepository> m_taxSettingsRepo;
    std::unique_ptr<MembershipRepository> m_membershipRepo;
    std::unique_ptr<MembershipSettingsRepository> m_membershipSettingsRepo;
    std::unique_ptr<MembershipTransactionRepository> m_membershipTransactionRepo;
    std::unique_ptr<RestaurantRepository> m_restaurantRepo;
    std::unique_ptr<ReceiptSnapshotRepository> m_receiptSnapshotRepo;
    std::unique_ptr<AppStateRepository> m_appStateRepo;
    std::unique_ptr<PrinterRepository> m_printerRepo;
    std::unique_ptr<RegionalSettingsRepository> m_regionalSettingsRepo;
    std::unique_ptr<UserRepository> m_userRepo;
    std::unique_ptr<KitchenSettingsRepository> m_kitchenSettingsRepo;
    std::unique_ptr<TableSettingsRepository> m_tableSettingsRepo;
    std::unique_ptr<ReservationRepository> m_reservationRepo;
    std::unique_ptr<PaymentRepository> m_paymentRepo;

    // services
    std::unique_ptr<MembershipService> m_membershipService;
    std::unique_ptr<SettingService> m_settingService;
    std::unique_ptr<TableService> m_tableService;
    std::unique_ptr<ReservationService> m_reservationService;
    std::unique_ptr<TaxCalculationService> m_taxCalculationService;
    std::unique_ptr<AuthService> m_authService;
    std::unique_ptr<CurrencyService> m_currencyService;
    std::unique_ptr<PaymentService> m_paymentService;

    std::unique_ptr<ReceiptBuilder> m_receiptBuilder;
    std::unique_ptr<WindowsPrinterService> m_windowsPrinterService;

    std::unique_ptr<CheckoutService> m_checkoutService;

    int m_defaultCategoryId = 0;
};

#endif // CHECKOUTSERVICETESTHELPER_H
