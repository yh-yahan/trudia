#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QSqlDatabase>
#include "core/utilities/Theme.h"
#include "core/utilities/SystemTheme.h"
#include "core/data/UserRepository.h"
#include "core/data/MenuRepository.h"
#include "core/data/CategoryRepository.h"
#include "core/data/OrderRepository.h"
#include "core/data/OrderItemRepository.h"
#include "core/data/OrderSessionRepository.h"
#include "core/data/TableRepository.h"
#include "core/data/RestaurantRepository.h"
#include "core/data/PrinterSettingRepository.h"
#include "core/data/TaxSettingsRepository.h"
#include "core/data/MembershipSettingsRepository.h"
#include "core/data/MembershipRepository.h"
#include "core/data/MembershipTransactionRepository.h"
#include "core/data/AnalyticsRepository.h"
#include "core/data/KitchenSettingsRepository.h"
#include "core/data/RegionalSettingsRepository.h"
#include "core/services/CurrencyService.h"
#include "core/services/OrderService.h"
#include "core/services/TableService.h"
#include "core/services/AuthService.h"
#include "core/services/MenuService.h"
#include "core/services/KitchenOrderService.h"
#include "core/services/CheckoutService.h"
#include "core/services/SettingService.h"
#include "core/services/TaxCalculationService.h"
#include "core/services/MembershipService.h"
#include "core/services/UserService.h"
#include "core/services/AnalyticsService.h"
#include "core/services/AppService.h"
#include "core/services/SetupService.h"
#include "core/database/DatabaseManager.h"
#include "core/printing/ReceiptBuilder.h"
#include "core/printing/NetworkPrinterService.h"
#include "core/printing/USBPrinterService.h"
#include "core/printing/KitchenPrinterService.h"
#include "core/printing/KitchenTicketBuilder.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QCoreApplication::setOrganizationName("Trudia");
    QCoreApplication::setApplicationName("TrudiaPOS");

    QTranslator translator;
    if (translator.load(QLocale(), "app", "_", ":/i18n")) {
        app.installTranslator(&translator);
    }

    DatabaseManager dbManager;

    AppService appService;

    QString dbPath = appService.databasePath();

    bool dbReady = false;

    if (!dbPath.isEmpty()) {
        dbReady = dbManager.initialize(dbPath);
    }

    SystemTheme systemTheme;
    Theme theme(&systemTheme);

    UserRepository userRepo(DatabaseManager::db());
    MenuRepository menuRepo(DatabaseManager::db());
    CategoryRepository categoryRepo(DatabaseManager::db());
    TableRepository tableRepo(DatabaseManager::db());
    OrderRepository orderRepo(DatabaseManager::db());
    OrderItemRepository orderItemRepo(DatabaseManager::db());
    OrderSessionRepository orderSessionRepo(DatabaseManager::db());
    RestaurantRepository restaurantRepo(DatabaseManager::db());
    PrinterSettingRepository printerSettingRepo(DatabaseManager::db());
    TaxSettingsRepository taxSettingsRepo(DatabaseManager::db());
    MembershipSettingsRepository membershipSettingsRepo(DatabaseManager::db());
    MembershipRepository membershipRepo(DatabaseManager::db());
    MembershipTransactionRepository membershipTransactionRepo(DatabaseManager::db());
    AnalyticsRepository analyticsRepo(DatabaseManager::db());
    KitchenSettingsRepository kitchenSettingsRepo(DatabaseManager::db());
    RegionalSettingsRepository regionalSettingsRepo(DatabaseManager::db());

    NetworkPrinterService networkPrinterService;
    USBPrinterService usbPrinterService;
    CurrencyService currencyService;
    TaxCalculationService taxCalculationService(taxSettingsRepo);
    MembershipService membershipService(membershipRepo, membershipSettingsRepo, membershipTransactionRepo);
    AuthService authService(userRepo);
    UserService userService(userRepo);
    MenuService menuService(menuRepo, categoryRepo);
    TableService tableService(tableRepo);
    SettingService settingService(
        restaurantRepo,
        printerSettingRepo,
        taxSettingsRepo,
        membershipSettingsRepo,
        kitchenSettingsRepo,
        regionalSettingsRepo,
        currencyService
    );
    KitchenPrinterService kitchenPrinterService(
        settingService,
        usbPrinterService,
        networkPrinterService
    );
    KitchenTicketBuilder kitchenTicketBuilder(settingService);
    ReceiptBuilder receiptBuilder(settingService);
    OrderService orderService(
        orderSessionRepo,
        orderRepo,
        orderItemRepo,
        tableRepo,
        menuRepo,
        taxCalculationService,
        kitchenPrinterService,
        kitchenTicketBuilder,
        settingService
    );
    KitchenOrderService kitchenOrderService(orderSessionRepo, orderRepo, orderItemRepo, tableRepo);
    CheckoutService checkoutService(
        orderSessionRepo,
        orderRepo,
        orderItemRepo,
        restaurantRepo,
        printerSettingRepo,
        tableRepo,
        membershipRepo,
        membershipTransactionRepo,
        receiptBuilder,
        networkPrinterService,
        usbPrinterService,
        taxCalculationService,
        membershipService,
        settingService
    );
    AnalyticsService analyticsService(analyticsRepo);
    SetupService setupService(appService, dbManager);

    QObject::connect(&orderService, &OrderService::orderCreated,
                 &kitchenOrderService, &KitchenOrderService::ordersChanged);

    QObject::connect(&orderService, &OrderService::orderUpdated,
                 &kitchenOrderService, &KitchenOrderService::ordersChanged);

    qmlRegisterSingletonInstance("trudia.System", 1, 0, "SystemTheme", &systemTheme);
    qmlRegisterSingletonInstance("trudia.Theme", 1, 0, "Theme", &theme);

    qmlRegisterSingletonInstance("Trudia.Services", 1, 0, "AuthService", &authService);
    qmlRegisterSingletonInstance("Trudia.Services", 1, 0, "UserService", &userService);
    qmlRegisterSingletonInstance("Trudia.Services", 1, 0, "MenuService", &menuService);
    qmlRegisterSingletonInstance("Trudia.Services", 1, 0, "TableService", &tableService);
    qmlRegisterSingletonInstance("Trudia.Services", 1, 0, "OrderService", &orderService);
    qmlRegisterSingletonInstance("Trudia.Services", 1, 0, "KitchenOrderService", &kitchenOrderService);
    qmlRegisterSingletonInstance("Trudia.Services", 1, 0, "CheckoutService", &checkoutService);
    qmlRegisterSingletonInstance("Trudia.Services", 1, 0, "SettingService", &settingService);
    qmlRegisterSingletonInstance("Trudia.Services", 1, 0, "MembershipService", &membershipService);
    qmlRegisterSingletonInstance("Trudia.Services", 1, 0, "AnalyticsService", &analyticsService);
    qmlRegisterSingletonInstance("Trudia.Services", 1, 0, "USBPrinterService", &usbPrinterService);
    qmlRegisterSingletonInstance("Trudia.Services", 1, 0, "AppService", &appService);
    qmlRegisterSingletonInstance("Trudia.Services", 1, 0, "SetupService", &setupService);

    QQmlApplicationEngine engine;
    engine.loadFromModule("trudia", "Main");

    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    return app.exec();
}
