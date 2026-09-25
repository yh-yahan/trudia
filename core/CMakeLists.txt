add_library(trudia_core STATIC)

target_sources(trudia_core PRIVATE
    database/DatabaseManager.cpp
    database/DatabaseSeeder.cpp
    
    data/UserRepository.cpp
    data/CategoryRepository.cpp
    data/MenuRepository.cpp
    data/TableRepository.cpp
    data/OrderRepository.cpp
    data/OrderItemRepository.cpp
    data/OrderSessionRepository.cpp
    data/RestaurantRepository.cpp
    data/TaxSettingsRepository.cpp
    data/MembershipRepository.cpp
    data/MembershipSettingsRepository.cpp
    data/MembershipTransactionRepository.cpp
    data/AnalyticsRepository.cpp
    data/KitchenSettingsRepository.cpp
    data/PrinterRepository.cpp
    data/RegionalSettingsRepository.cpp
    data/CanvasItemRepository.cpp
    data/FloorRepository.cpp
    data/TableSettingsRepository.cpp
    data/ReservationRepository.cpp
    data/AppStateRepository.cpp
    data/ReceiptSnapshotRepository.cpp
    data/TaxReportRepository.cpp
    data/PaymentRepository.cpp
    data/ModifiersRepository.cpp
    data/OrderItemModifierRepository.cpp
    data/InventoryItemRepository.cpp
    data/StockMovementRepository.cpp
    data/RecipeComponentRepository.cpp

    services/AuthService.cpp
    services/MenuService.cpp
    services/TableService.cpp
    services/OrderService.cpp
    services/KitchenOrderService.cpp
    services/CheckoutService.cpp
    services/SettingService.cpp
    services/TaxCalculationService.cpp
    services/MembershipService.cpp
    services/UserService.cpp
    services/AnalyticsService.cpp
    services/CurrencyService.cpp
    services/RegionalSettingsService.cpp
    services/FloorPlanService.cpp
    services/ReservationService.cpp
    services/DatabaseService.cpp
    services/DatabaseRestoreService.cpp
    services/AppService.cpp
    services/SetupService.cpp
    services/BetaService.cpp
    services/MemberService.cpp
    services/TaxReportService.cpp
    services/PaymentService.cpp
    services/ModifiersService.cpp
    services/InventoryService.cpp

    printing/EscPosBuilder.cpp
    printing/PrintLayoutHelper.cpp
    printing/WindowsPrinterService.cpp
    printing/KitchenTicketBuilder.cpp
    printing/ReceiptBuilder.cpp

    models/CategoryModel.cpp
    models/MenuItemModel.cpp
    models/TableModel.cpp
    models/UserModel.cpp
    models/FloorModel.cpp
    models/CanvasItemModel.cpp
    models/MemberListModel.cpp
    models/MemberTransactionModel.cpp
    models/ModifiersModel.cpp

    utilities/PasswordHasher.cpp
    utilities/SystemTheme.cpp
    utilities/Theme.h

    logging/LogManager.cpp
    logging/LoggingCategories.cpp
)

target_include_directories(trudia_core
    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}
)

target_link_libraries(trudia_core
    PUBLIC
        Qt6::Core
        Qt6::Gui
        Qt6::Network
        Qt6::Sql
        Qt6::Concurrent
        sodium
)
