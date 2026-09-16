#ifndef APPCOMPOSITION_H
#define APPCOMPOSITION_H

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
#include "core/data/TaxReportRepository.h"
#include "core/data/PaymentRepository.h"
#include "core/data/ModifiersRepository.h"
#include "core/data/OrderItemModifierRepository.h"

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
#include "core/services/DatabaseService.h"
#include "core/services/ReservationService.h"
#include "core/services/BetaService.h"
#include "core/services/MemberService.h"
#include "core/services/TaxReportService.h"
#include "core/services/PaymentService.h"
#include "core/services/ModifiersService.h"

#include "core/printing/ReceiptBuilder.h"
#include "core/printing/WindowsPrinterService.h"
#include "core/printing/KitchenTicketBuilder.h"

class AppService;
class DatabaseManager;

class AppComposition
{
public:
    AppComposition(AppService& appService, DatabaseManager& dbManager);

    void registerQml();

private:
    void wireSignals();

    UserRepository userRepo;
    MenuRepository menuRepo;
    CategoryRepository categoryRepo;
    TableRepository tableRepo;
    OrderRepository orderRepo;
    OrderItemRepository orderItemRepo;
    OrderSessionRepository orderSessionRepo;
    RestaurantRepository restaurantRepo;
    PrinterRepository printerRepo;
    TaxSettingsRepository taxSettingsRepo;
    MembershipSettingsRepository membershipSettingsRepo;
    MembershipRepository membershipRepo;
    MembershipTransactionRepository membershipTransactionRepo;
    AnalyticsRepository analyticsRepo;
    KitchenSettingsRepository kitchenSettingsRepo;
    RegionalSettingsRepository regionalSettingsRepo;
    FloorRepository floorRepo;
    CanvasItemRepository canvasItemRepo;
    TableSettingsRepository tableSettingsRepo;
    ReservationRepository reservationRepo;
    AppStateRepository appStateRepo;
    ReceiptSnapshotRepository receiptSnapshotRepo;
    TaxReportRepository taxReportRepo;
    PaymentRepository paymentRepo;
    ModifiersRepository modifiersRepo;
    OrderItemModifierRepository orderItemModifierRepo;

    WindowsPrinterService windowsPrinterService;
    CurrencyService currencyService;
    TaxCalculationService taxCalculationService;
    BetaService betaService;
    MembershipService membershipService;
    AuthService authService;
    UserService userService;
    MenuService menuService;
    TableService tableService;
    SettingService settingService;
    KitchenTicketBuilder kitchenTicketBuilder;
    ReceiptBuilder receiptBuilder;
    ReservationService reservationService;
    PaymentService paymentService;
    KitchenOrderService kitchenOrderService;
    CheckoutService checkoutService;
    AnalyticsService analyticsService;
    FloorPlanService floorPlanService;
    OrderService orderService;
    MemberService memberService;
    DatabaseService databaseService;
    TaxReportService taxReportService;
    ModifiersService modifiersService;
};

#endif // APPCOMPOSITION_H
