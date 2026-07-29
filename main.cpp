#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QSqlDatabase>
#include <QQuickStyle>
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
#include "core/data/PrinterRepository.h"
#include "core/data/TaxSettingsRepository.h"
#include "core/data/MembershipSettingsRepository.h"
#include "core/data/MembershipRepository.h"
#include "core/data/MembershipTransactionRepository.h"
#include "core/data/AnalyticsRepository.h"
#include "core/data/KitchenSettingsRepository.h"
#include "core/data/RegionalSettingsRepository.h"
#include "core/data/FloorRepository.h"
#include "core/data/CanvasItemRepository.h"
#include "core/data/TableSettingsRepository.h"
#include "core/data/ReservationRepository.h"
#include "core/data/AppStateRepository.h"
#include "core/data/ReceiptSnapshotRepository.h"
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
#include "core/services/FloorPlanService.h"
#include "core/services/AppService.h"
#include "core/services/SetupService.h"
#include "core/services/DatabaseService.h"
#include "core/services/ReservationService.h"
#include "core/services/DatabaseRestoreService.h"
#include "core/services/BetaService.h"
#include "core/database/DatabaseManager.h"
#include "core/printing/ReceiptBuilder.h"
#include "core/printing/WindowsPrinterService.h"
#include "core/printing/KitchenTicketBuilder.h"
#include "core/logging/LogManager.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QCoreApplication::setOrganizationName("Trudia");
    QCoreApplication::setApplicationName("TrudiaPOS");

    LogManager::initialize();

    QQuickStyle::setStyle("Fusion");

    DatabaseRestoreService::processPendingRestore();

    AppService appService;

    QString dbPath = appService.databasePath();

    DatabaseManager dbManager;

    if (!dbPath.isEmpty()) {
        dbManager.initialize(dbPath);
    }

    SystemTheme systemTheme;
    Theme theme(&systemTheme);

    auto regionalOpt = RegionalSettingsRepository(DatabaseManager::db()).get();

    QString locale;

    if (regionalOpt.has_value() && !regionalOpt->locale.isEmpty()) {
        locale = regionalOpt->locale;
    } else {
        locale = QLocale::system().name();
    }

    QTranslator translator;

    const QString translationFile = QString("app_%1").arg(locale);

    if (translator.load(QLocale(locale), "app", "_", ":/i18n")) {
        app.installTranslator(&translator);
    } else {
        QLocale fallbackLocale(locale);
        if (translator.load(fallbackLocale, "app", "_", ":/i18n")) {
            app.installTranslator(&translator);
        }
    }

    UserRepository userRepo(DatabaseManager::db());
    MenuRepository menuRepo(DatabaseManager::db());
    CategoryRepository categoryRepo(DatabaseManager::db());
    TableRepository tableRepo(DatabaseManager::db());
    OrderRepository orderRepo(DatabaseManager::db());
    OrderItemRepository orderItemRepo(DatabaseManager::db());
    OrderSessionRepository orderSessionRepo(DatabaseManager::db());
    RestaurantRepository restaurantRepo(DatabaseManager::db());
    PrinterRepository printerRepo(DatabaseManager::db());
    TaxSettingsRepository taxSettingsRepo(DatabaseManager::db());
    MembershipSettingsRepository membershipSettingsRepo(DatabaseManager::db());
    MembershipRepository membershipRepo(DatabaseManager::db());
    MembershipTransactionRepository membershipTransactionRepo(DatabaseManager::db());
    AnalyticsRepository analyticsRepo(DatabaseManager::db());
    KitchenSettingsRepository kitchenSettingsRepo(DatabaseManager::db());
    RegionalSettingsRepository regionalSettingsRepo(DatabaseManager::db());
    FloorRepository floorRepo(DatabaseManager::db());
    CanvasItemRepository canvasItemRepo(DatabaseManager::db());
    TableSettingsRepository tableSettingsRepo(DatabaseManager::db());
    ReservationRepository reservationRepo(DatabaseManager::db());
    AppStateRepository appStateRepo(DatabaseManager::db());
    ReceiptSnapshotRepository receiptSnapshotRepo(DatabaseManager::db());

    WindowsPrinterService windowsPrinterService;
    CurrencyService currencyService;
    TaxCalculationService taxCalculationService;
    BetaService betaService;
    MembershipService membershipService(membershipRepo, membershipSettingsRepo, membershipTransactionRepo);
    AuthService authService(userRepo);
    UserService userService(userRepo);
    MenuService menuService(menuRepo, categoryRepo);
    TableService tableService(tableRepo);
    SettingService settingService(
        restaurantRepo,
        printerRepo,
        taxSettingsRepo,
        membershipSettingsRepo,
        kitchenSettingsRepo,
        regionalSettingsRepo,
        tableSettingsRepo,
        currencyService
    );
    KitchenTicketBuilder kitchenTicketBuilder(regionalSettingsRepo);
    ReceiptBuilder receiptBuilder(regionalSettingsRepo);
    ReservationService reservationService(reservationRepo, tableService);
    KitchenOrderService kitchenOrderService(
        orderSessionRepo, 
        orderRepo, 
        orderItemRepo, 
        tableRepo);
    CheckoutService checkoutService(
        orderSessionRepo,
        orderRepo,
        orderItemRepo,
        restaurantRepo,
        printerRepo,
        tableRepo,
        membershipRepo,
        membershipTransactionRepo,
        taxSettingsRepo,
        appStateRepo,
        receiptSnapshotRepo,
        regionalSettingsRepo,
        receiptBuilder,
        windowsPrinterService,
        taxCalculationService,
        membershipService,
        settingService,
        tableService,
        reservationService,
        authService,
        dbManager
    );
    AnalyticsService analyticsService(analyticsRepo);
    FloorPlanService floorPlanService(
        floorRepo,
        canvasItemRepo,
        tableRepo,
        reservationRepo,
        tableService);
    SetupService setupService(appService, dbManager);
    OrderService orderService(
        orderSessionRepo,
        orderRepo,
        orderItemRepo,
        tableRepo,
        menuRepo,
        printerRepo,
        taxCalculationService,
        kitchenTicketBuilder,
        settingService,
        windowsPrinterService,
        tableService,
        reservationService,
        checkoutService
    );
    DatabaseService databaseService(
        appService,
        dbManager
    );

    QObject::connect(&orderService, &OrderService::orderCreated,
                 &kitchenOrderService, &KitchenOrderService::ordersChanged);

    QObject::connect(&orderService, &OrderService::orderUpdated,
                 &kitchenOrderService, &KitchenOrderService::ordersChanged);

    QObject::connect(&reservationService, &ReservationService::reservationChanged,
        &floorPlanService,
        [&floorPlanService](int tableId)
        {
            Q_UNUSED(tableId);

            floorPlanService.loadCanvas(
                floorPlanService.currentFloorId());
        });

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
    qmlRegisterSingletonInstance("Trudia.Services", 1, 0, "WindowsPrinterService", &windowsPrinterService);
    qmlRegisterSingletonInstance("Trudia.Services", 1, 0, "FloorPlanService", &floorPlanService);
    qmlRegisterSingletonInstance("Trudia.Services", 1, 0, "AppService", &appService);
    qmlRegisterSingletonInstance("Trudia.Services", 1, 0, "SetupService", &setupService);
    qmlRegisterSingletonInstance("Trudia.Services", 1, 0, "ReservationService", &reservationService);
    qmlRegisterSingletonInstance("Trudia.Services", 1, 0, "DatabaseService", &databaseService);
    qmlRegisterSingletonInstance("Trudia.Services", 1, 0, "BetaService", &betaService);

    QQmlApplicationEngine engine;
    engine.loadFromModule("trudia", "Main");

    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    return app.exec();
}
