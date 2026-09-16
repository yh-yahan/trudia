cmake_minimum_required(VERSION 3.16)

project(trudia VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_PREFIX_PATH "C:/Qt/6.10.2/mingw_64")

find_package(Qt6 REQUIRED COMPONENTS Quick QuickControls2 Network Sql LinguistTools Concurrent Test)

set(LIBSODIUM_ROOT "C:/libsodium/libsodium-win64")

include_directories("${LIBSODIUM_ROOT}/include")

link_directories("${LIBSODIUM_ROOT}/lib")

qt_standard_project_setup(REQUIRES 6.8)

add_subdirectory(core)

enable_testing()
add_subdirectory(tests)

qt_add_executable(apptrudia
    main.cpp
    AppComposition.cpp
    AppComposition.h
    app.rc
)

set_source_files_properties(resources.qrc
    PROPERTIES QT_RESOURCE_ALIAS resources.qrc
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
        qml/components/OrderEditor.qml
        qml/components/TimePicker.qml
        qml/components/DatePicker.qml
        qml/components/ModifierPickerDialog.qml
        qml/setup/SetupDBChoice.qml
        qml/setup/SetupDBCreation.qml
        qml/setup/SetupDBOpen.qml
        qml/setup/SetupAdmin.qml
        qml/setup/SetupBetaWelcome.qml
        qml/common/OrderTaking.qml
        qml/common/OrderTakingSimple.qml
        qml/common/OrderTakingFloorPlan.qml
        qml/common/Checkout.qml
        qml/common/KitchenOrders.qml
        qml/common/floor/FloorPlanView.qml
        qml/auth/Login.qml
        qml/admin/AdminHome.qml
        qml/admin/AdminSidebar.qml
        qml/admin/AdminAnalytics.qml
        qml/admin/AdminTaxReports.qml
        qml/admin/management/AdminMenuManagement.qml
        qml/admin/management/AdminTableManagement.qml
        qml/admin/management/AdminFloorPlanManagement.qml
        qml/admin/management/AdminMembersManagement.qml
        qml/admin/management/AdminUserManagement.qml
        qml/admin/management/AdminManagement.qml
        qml/admin/management/AdminManagementSidebar.qml
        qml/admin/settings/AdminDatabaseSettings.qml
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
)

qt_add_translations(apptrudia
    TS_FILES translations/app_zh_CN.ts
    RESOURCE_PREFIX "/i18n"
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(apptrudia PROPERTIES
    OUTPUT_NAME "Trudia"
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.apptrudia
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(apptrudia
    PRIVATE
        trudia_core
        Qt6::Quick
        Qt6::QuickControls2
        Qt6::Network
        Qt6::Sql
        Qt6::Concurrent
        sodium
)

include(GNUInstallDirs)
install(TARGETS apptrudia
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
