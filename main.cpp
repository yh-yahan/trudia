#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QSqlDatabase>
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
#include "core/database/DatabaseManager.h"
#include "core/printing/ReceiptFormatter.h"
#include "core/printing/NetworkPrinterService.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QTranslator translator;
    if (translator.load(QLocale(), "app", "_", ":/i18n")) {
        app.installTranslator(&translator);
    }

    if (!DatabaseManager::initialize()){
        qWarning() << "Database initialization failed";
        return -1;
    }

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

    ReceiptFormatter receiptFormatter;
    NetworkPrinterService networkPrinterService;
    TaxCalculationService taxCalculationService(taxSettingsRepo);
    MembershipService membershipService(membershipRepo, membershipSettingsRepo, membershipTransactionRepo);
    AuthService authService(userRepo);
    UserService userService(userRepo);
    MenuService menuService(menuRepo, categoryRepo);
    TableService tableService(tableRepo);
    OrderService orderService(
        orderSessionRepo,
        orderRepo,
        orderItemRepo,
        tableRepo,
        menuRepo,
        taxCalculationService
    );
    KitchenOrderService kitchenOrderService(orderSessionRepo, orderRepo, orderItemRepo);
    CheckoutService checkoutService(
        orderSessionRepo,
        orderRepo,
        orderItemRepo,
        restaurantRepo,
        printerSettingRepo,
        tableRepo,
        membershipRepo,
        receiptFormatter,
        networkPrinterService,
        taxCalculationService,
        membershipService
    );
    SettingService settingService(
        restaurantRepo,
        printerSettingRepo,
        taxSettingsRepo,
        membershipSettingsRepo
    );
    AnalyticsService analyticsService(analyticsRepo);

    qmlRegisterSingletonInstance("Xeno.Services", 1, 0, "AuthService", &authService);
    qmlRegisterSingletonInstance("Xeno.Services", 1, 0, "UserService", &userService);
    qmlRegisterSingletonInstance("Xeno.Services", 1, 0, "MenuService", &menuService);
    qmlRegisterSingletonInstance("Xeno.Services", 1, 0, "TableService", &tableService);
    qmlRegisterSingletonInstance("Xeno.Services", 1, 0, "OrderService", &orderService);
    qmlRegisterSingletonInstance("Xeno.Services", 1, 0, "KitchenOrderService", &kitchenOrderService);
    qmlRegisterSingletonInstance("Xeno.Services", 1, 0, "CheckoutService", &checkoutService);
    qmlRegisterSingletonInstance("Xeno.Services", 1, 0, "SettingService", &settingService);
    qmlRegisterSingletonInstance("Xeno.Services", 1, 0, "MembershipService", &membershipService);
    qmlRegisterSingletonInstance("Xeno.Services", 1, 0, "AnalyticsService", &analyticsService);

    QQmlApplicationEngine engine;
    engine.loadFromModule("xeno", "Main");

    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    return app.exec();
}
