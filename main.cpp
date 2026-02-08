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
#include "core/services/OrderService.h"
#include "core/data/TableRepository.h"
#include "core/services/TableService.h"
#include "core/services/AuthService.h"
#include "core/services/MenuService.h"
#include "core/database/DatabaseManager.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    if (!DatabaseManager::initialize()){
        qWarning() << "Database initialization failed";
        return -1;
    }

    UserRepository repo(DatabaseManager::db());
    MenuRepository menuRepo(DatabaseManager::db());
    CategoryRepository categoryRepo(DatabaseManager::db());
    TableRepository tableRepo(DatabaseManager::db());
    OrderRepository orderRepo(DatabaseManager::db());
    OrderItemRepository orderItemRepo(DatabaseManager::db());
    OrderSessionRepository orderSessionRepo(DatabaseManager::db());

    AuthService authService(repo);
    MenuService menuService(menuRepo, categoryRepo);
    TableService tableService(tableRepo);
    OrderService orderService(orderSessionRepo, orderRepo, orderItemRepo, tableRepo);

    qmlRegisterSingletonInstance("Xeno.Services", 1, 0, "AuthService", &authService);
    qmlRegisterSingletonInstance("Xeno.Services", 1, 0, "MenuService", &menuService);
    qmlRegisterSingletonInstance("Xeno.Services", 1, 0, "TableService", &tableService);
    qmlRegisterSingletonInstance("Xeno.Services", 1, 0, "OrderService", &orderService);

    QQmlApplicationEngine engine;
    engine.loadFromModule("xeno", "Main");

    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    return app.exec();
}
