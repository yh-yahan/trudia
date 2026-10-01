#include "AppComposition.h"

#include "core/services/AppService.h"
#include "core/database/DatabaseManager.h"

#include <QObject>
#include <QQmlEngine>

AppComposition::AppComposition(AppService& appService, DatabaseManager& dbManager)
    : userRepo(DatabaseManager::db()),
      menuRepo(DatabaseManager::db()),
      categoryRepo(DatabaseManager::db()),
      tableRepo(DatabaseManager::db()),
      orderRepo(DatabaseManager::db()),
      orderItemRepo(DatabaseManager::db()),
      orderSessionRepo(DatabaseManager::db()),
      restaurantRepo(DatabaseManager::db()),
      printerRepo(DatabaseManager::db()),
      taxSettingsRepo(DatabaseManager::db()),
      membershipSettingsRepo(DatabaseManager::db()),
      membershipRepo(DatabaseManager::db()),
      membershipTransactionRepo(DatabaseManager::db()),
      analyticsRepo(DatabaseManager::db()),
      kitchenSettingsRepo(DatabaseManager::db()),
      regionalSettingsRepo(DatabaseManager::db()),
      floorRepo(DatabaseManager::db()),
      canvasItemRepo(DatabaseManager::db()),
      tableSettingsRepo(DatabaseManager::db()),
      reservationRepo(DatabaseManager::db()),
      appStateRepo(DatabaseManager::db()),
      receiptSnapshotRepo(DatabaseManager::db()),
      taxReportRepo(DatabaseManager::db()),
      paymentRepo(DatabaseManager::db()),
      modifiersRepo(DatabaseManager::db()),
      orderItemModifierRepo(DatabaseManager::db()),
      inventoryItemRepo(DatabaseManager::db()),
      stockMovementRepo(DatabaseManager::db()),
      recipeComponentRepo(DatabaseManager::db()),
      membershipService(membershipRepo, membershipSettingsRepo, membershipTransactionRepo),
      authService(userRepo),
      userService(userRepo),
      menuService(menuRepo, categoryRepo),
      tableService(tableRepo),
      settingService(
          restaurantRepo,
          printerRepo,
          taxSettingsRepo,
          membershipSettingsRepo,
          kitchenSettingsRepo,
          regionalSettingsRepo,
          tableSettingsRepo,
          currencyService),
      kitchenTicketBuilder(regionalSettingsRepo),
      receiptBuilder(regionalSettingsRepo),
      reservationService(reservationRepo, tableService),
      paymentService(paymentRepo),
      kitchenOrderService(
          orderSessionRepo,
          orderRepo,
          orderItemRepo,
          orderItemModifierRepo,
          tableRepo),
      checkoutService(
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
          orderItemModifierRepo,
          receiptBuilder,
          windowsPrinterService,
          taxCalculationService,
          membershipService,
          settingService,
          tableService,
          reservationService,
          authService,
          paymentService,
          dbManager),
      analyticsService(analyticsRepo),
      floorPlanService(
          floorRepo,
          canvasItemRepo,
          tableRepo,
          reservationRepo,
          tableService),
      orderService(
          orderSessionRepo,
          orderRepo,
          orderItemRepo,
          tableRepo,
          menuRepo,
          printerRepo,
          orderItemModifierRepo,
          modifiersRepo,
          taxCalculationService,
          kitchenTicketBuilder,
          settingService,
          windowsPrinterService,
          tableService,
          reservationService,
          checkoutService),
      memberService(dbManager, membershipRepo, membershipTransactionRepo),
      databaseService(appService, dbManager),
      taxReportService(taxReportRepo),
      modifiersService(modifiersRepo),
      inventoryService(
          inventoryItemRepo,
          recipeComponentRepo,
          stockMovementRepo,
          orderItemRepo,
          dbManager)
{
    wireSignals();
}

void AppComposition::wireSignals()
{
    QObject::connect(&orderService, &OrderService::orderCreated,
                     &kitchenOrderService, &KitchenOrderService::ordersChanged);

    QObject::connect(&orderService, &OrderService::orderUpdated,
                     &kitchenOrderService, &KitchenOrderService::ordersChanged);

    QObject::connect(&reservationService, &ReservationService::reservationChanged,
                     &floorPlanService,
                     [this](int tableId) {
                         Q_UNUSED(tableId);
                         floorPlanService.loadCanvas(floorPlanService.currentFloorId());
                     });
}

void AppComposition::registerQml()
{
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
    qmlRegisterSingletonInstance("Trudia.Services", 1, 0, "ReservationService", &reservationService);
    qmlRegisterSingletonInstance("Trudia.Services", 1, 0, "BetaService", &betaService);
    qmlRegisterSingletonInstance("Trudia.Services", 1, 0, "MemberService", &memberService);
    qmlRegisterSingletonInstance("Trudia.Services", 1, 0, "TaxReportService", &taxReportService);
    qmlRegisterSingletonInstance("Trudia.Services", 1, 0, "ModifiersService", &modifiersService);
    qmlRegisterSingletonInstance("Trudia.Services", 1, 0, "InventoryService", &inventoryService);
}
