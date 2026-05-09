cmake_minimum_required(VERSION 3.16)

project(trudia VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_PREFIX_PATH "C:/Qt/6.10.2/mingw_64")

find_package(Qt6 REQUIRED COMPONENTS Quick Sql LinguistTools Concurrent SerialPort)

set(LIBSODIUM_ROOT "C:/libsodium/libsodium-win64")

include_directories("${LIBSODIUM_ROOT}/include")

link_directories("${LIBSODIUM_ROOT}/lib")

qt_standard_project_setup(REQUIRES 6.8)

qt_add_executable(apptrudia
    main.cpp
    app.rc
)

qt_add_resources(app_resources resources.qrc)
target_sources(apptrudia PRIVATE ${app_resources})

qt_add_qml_module(apptrudia
    URI trudia
    QML_FILES
        qml/Main.qml
        qml/components/ConfirmationDialog.qml
        qml/components/FloorCanvas.qml
        qml/components/FloorItem.qml
        qml/setup/SetupAdmin.qml
        qml/setup/SetupDBLocation.qml
        qml/common/OrderTaking.qml
        qml/common/Checkout.qml
        qml/common/KitchenOrders.qml
        qml/auth/Login.qml
        qml/admin/AdminHome.qml
        qml/admin/AdminSidebar.qml
        qml/admin/AdminAnalytics.qml
        qml/admin/management/AdminMenuManagement.qml
        qml/admin/management/AdminTableManagement.qml
        qml/admin/management/AdminFloorPlanManagement.qml
        qml/admin/management/AdminUserManagement.qml
        qml/admin/management/AdminManagement.qml
        qml/admin/management/AdminManagementSidebar.qml
        qml/admin/settings/AdminRegionalSettings.qml
        qml/admin/settings/AdminKitchenSettings.qml
        qml/admin/settings/AdminStoreSettings.qml
        qml/admin/settings/AdminPrinterSettings.qml
        qml/admin/settings/AdminTaxSettings.qml
        qml/admin/settings/AdminMembershipSettings.qml
        qml/admin/settings/AdminTableSettings.qml
        qml/admin/settings/AdminSettings.qml
        qml/admin/settings/AdminSettingsSidebar.qml
        qml/serviceStaff/ServiceStaffHome.qml
        qml/serviceStaff/ServiceStaffSidebar.qml
        qml/kitchenStaff/KitchenStaffHome.qml

    SOURCES core/database/DatabaseManager.h
    SOURCES core/database/DatabaseManager.cpp
    SOURCES core/domain/User.h
    SOURCES core/data/UserRepository.h core/data/UserRepository.cpp
    SOURCES core/services/AuthService.h core/services/AuthService.cpp
    SOURCES core/services/MenuService.h core/services/MenuService.cpp
    SOURCES core/data/CategoryRepository.h core/data/CategoryRepository.cpp
    SOURCES core/data/MenuRepository.h core/data/MenuRepository.cpp
    SOURCES core/data/TableRepository.h core/data/TableRepository.cpp
    SOURCES core/data/OrderRepository.h core/data/OrderRepository.cpp
    SOURCES core/data/OrderItemRepository.h core/data/OrderItemRepository.cpp
    SOURCES core/domain/Table.h
    SOURCES core/domain/Category.h
    SOURCES core/domain/Menu.h
    SOURCES core/domain/Order.h
    SOURCES core/domain/OrderItem.h
    SOURCES core/services/TableService.h core/services/TableService.cpp
    SOURCES core/services/OrderService.h core/services/OrderService.cpp
    SOURCES core/domain/OrderSession.h
    SOURCES core/data/OrderSessionRepository.h core/data/OrderSessionRepository.cpp
    SOURCES core/services/KitchenOrderService.h core/services/KitchenOrderService.cpp
    SOURCES core/services/CheckoutService.h core/services/CheckoutService.cpp
    SOURCES core/data/RestaurantRepository.h core/data/RestaurantRepository.cpp
    SOURCES core/domain/Restaurant.h
    SOURCES core/services/SettingService.h core/services/SettingService.cpp
    SOURCES core/printing/EscPosBuilder.h core/printing/EscPosBuilder.cpp
    SOURCES core/domain/TaxSettings.h
    SOURCES core/data/TaxSettingsRepository.h core/data/TaxSettingsRepository.cpp
    SOURCES core/services/TaxCalculationService.h core/services/TaxCalculationService.cpp
    SOURCES core/domain/MembershipSettings.h
    SOURCES core/data/MembershipSettingsRepository.h core/data/MembershipSettingsRepository.cpp
    SOURCES core/domain/Membership.h
    SOURCES core/domain/MembershipTransaction.h
    SOURCES core/data/MembershipRepository.h core/data/MembershipRepository.cpp
    SOURCES core/data/MembershipTransactionRepository.h core/data/MembershipTransactionRepository.cpp
    SOURCES core/services/MembershipService.h core/services/MembershipService.cpp
    SOURCES core/services/UserService.h core/services/UserService.cpp
    SOURCES core/utilities/PasswordHasher.h core/utilities/PasswordHasher.cpp
    SOURCES core/services/AnalyticsService.h core/services/AnalyticsService.cpp
    SOURCES core/data/AnalyticsRepository.h core/data/AnalyticsRepository.cpp
    SOURCES core/domain/KitchenSettings.h
    SOURCES core/data/KitchenSettingsRepository.h core/data/KitchenSettingsRepository.cpp
    SOURCES core/domain/OpenOrderView.h
    SOURCES core/printing/PrintLayoutHelper.h core/printing/PrintLayoutHelper.cpp
    SOURCES core/printing/WindowsPrinterService.h core/printing/WindowsPrinterService.cpp
    SOURCES core/printing/KitchenTicketBuilder.h core/printing/KitchenTicketBuilder.cpp
    SOURCES core/services/AppService.h core/services/AppService.cpp
    SOURCES core/services/SetupService.h core/services/SetupService.cpp
    SOURCES core/printing/ReceiptBuilder.h core/printing/ReceiptBuilder.cpp
    SOURCES core/domain/ReceiptData.h
    SOURCES core/models/CategoryModel.h core/models/CategoryModel.cpp
    SOURCES core/models/MenuItemModel.h core/models/MenuItemModel.cpp
    SOURCES core/models/TableModel.h core/models/TableModel.cpp
    SOURCES core/models/UserModel.h core/models/UserModel.cpp
    SOURCES core/utilities/SystemTheme.h core/utilities/SystemTheme.cpp
    SOURCES core/utilities/Theme.h
    SOURCES core/data/RegionalSettingsRepository.h core/data/RegionalSettingsRepository.cpp
    SOURCES core/domain/RegionalSettings.h
    SOURCES core/services/CurrencyService.h core/services/CurrencyService.cpp
    SOURCES core/domain/Printer.h
    SOURCES core/data/PrinterRepository.h core/data/PrinterRepository.cpp
    SOURCES core/services/RegionalSettingsService.h core/services/RegionalSettingsService.cpp
    SOURCES core/domain/CanvasItem.h
    SOURCES core/domain/Floor.h
    SOURCES core/data/CanvasItemRepository.h core/data/CanvasItemRepository.cpp
    SOURCES core/data/FloorRepository.h core/data/FloorRepository.cpp
    SOURCES core/services/FloorPlanService.h core/services/FloorPlanService.cpp
    SOURCES core/models/FloorModel.h core/models/FloorModel.cpp
    SOURCES core/models/CanvasItemModel.h core/models/CanvasItemModel.cpp
    SOURCES core/domain/TableSettings.h
    SOURCES core/data/TableSettingsRepository.h core/data/TableSettingsRepository.cpp
)

qt_add_translations(apptrudia
    TS_FILES translations/app_zh_CN.ts
    RESOURCE_PREFIX "/i18n"
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(apptrudia PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.apptrudia
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(apptrudia
    PRIVATE
        Qt6::Quick
        Qt6::Sql
        Qt6::Concurrent
        Qt6::SerialPort
        sodium
)

include(GNUInstallDirs)
install(TARGETS apptrudia
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
