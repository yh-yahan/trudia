#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickStyle>
#include <QTranslator>
#include <optional>
#include "AppComposition.h"
#include "core/utilities/Theme.h"
#include "core/utilities/SystemTheme.h"
#include "core/data/RegionalSettingsRepository.h"
#include "core/services/AppService.h"
#include "core/services/SetupService.h"
#include "core/services/DatabaseRestoreService.h"
#include "core/services/DatabaseService.h"
#include "core/database/DatabaseManager.h"
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
    DatabaseManager dbManager;

    const auto state = appService.determineState();
    const bool needsSetup = state == AppService::NeedsSetup ||
        state == AppService::FileNotFoundNeedsSetup ||
        state == AppService::UnableToOpenNeedsSetup ||
        state == AppService::NotTrudiaDBNeedsSetup;

    if (!needsSetup) dbManager.initialize(appService.databasePath());

    DatabaseService databaseService(appService, dbManager);
    qmlRegisterSingletonInstance("Trudia.Services", 1, 0, "DatabaseService", &databaseService);

    SystemTheme systemTheme;
    Theme theme(&systemTheme);
    SetupService setupService(appService, dbManager);

    QString locale = QLocale::system().name();
    if (!needsSetup) {
        const auto regionalOpt = RegionalSettingsRepository(DatabaseManager::db()).get();
        if (regionalOpt.has_value() && !regionalOpt->locale.isEmpty()) locale = regionalOpt->locale;
    }

    QTranslator translator;
    if (translator.load(QLocale(locale), "app", "_", ":/i18n")) {
        app.installTranslator(&translator);
    } else {
        QLocale fallbackLocale(locale);
        if (translator.load(fallbackLocale, "app", "_", ":/i18n"))
            app.installTranslator(&translator);
    }

    std::optional<AppComposition> composition;
    if (!needsSetup) composition.emplace(appService, dbManager);

    qmlRegisterSingletonInstance("trudia.System", 1, 0, "SystemTheme", &systemTheme);
    qmlRegisterSingletonInstance("trudia.Theme", 1, 0, "Theme", &theme);
    qmlRegisterSingletonInstance("Trudia.Services", 1, 0, "AppService", &appService);
    qmlRegisterSingletonInstance("Trudia.Services", 1, 0, "SetupService", &setupService);

    if (composition) composition->registerQml();

    QQmlApplicationEngine engine;
    engine.loadFromModule("trudia", "Main");
    if (engine.rootObjects().isEmpty()) return -1;

    return app.exec();
}
