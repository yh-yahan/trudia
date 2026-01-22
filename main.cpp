#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "core/data/UserRepository.h"
#include "core/services/AuthService.h"
#include <QSqlDatabase>
#include "core/database/DatabaseManager.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    if (!DatabaseManager::initialize()){
        qWarning() << "Database initialization failed";
        return -1;
    }

    UserRepository repo(DatabaseManager::db());
    AuthService authService(repo);

    qmlRegisterSingletonInstance(
        "Xeno.Services",
        1, 0,
        "AuthService",
        &authService
    );

    QQmlApplicationEngine engine;

    engine.loadFromModule("xeno", "Main");

    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    return app.exec();
}
