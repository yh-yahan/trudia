cmake_minimum_required(VERSION 3.16)

project(xeno VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick Sql)

qt_standard_project_setup(REQUIRES 6.8)

qt_add_executable(appxeno
    main.cpp
)

qt_add_resources(app_resources resources.qrc)
target_sources(appxeno PRIVATE ${app_resources})

qt_add_qml_module(appxeno
    URI xeno
    QML_FILES
        qml/Main.qml
        qml/components/ConfirmationDialog.qml
        qml/auth/Login.qml
        qml/auth/FirstAdminRegister.qml
        qml/admin/AdminHome.qml
        qml/admin/AdminSidebar.qml
        qml/admin/AdminMenuManagement.qml
        qml/admin/AdminTableManagement.qml

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
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appxeno PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appxeno
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appxeno
    PRIVATE
        Qt6::Quick
        Qt6::Sql
)

include(GNUInstallDirs)
install(TARGETS appxeno
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
