#include "SetupService.h"

#include <QFile>
#include "../data/RegionalSettingsRepository.h"
#include "./RegionalSettingsService.h"
#include "../logging/LoggingCategories.h"

SetupService::SetupService(AppService &appService,
                           DatabaseManager &databaseManager,
                           QObject *parent)
    : QObject(parent),
      m_appService(appService),
      m_databaseManager(databaseManager) {}

SetupService::SetupResult SetupService::initializeSystem(const QString &dbPath)
{
    qCInfo(logApplication) << "Starting system initialization...";

    if (dbPath.isEmpty()) {
        qCInfo(logSetup) << "Invalid setup input.";
        return InvalidPath;
    }

    if (QFile::exists(dbPath)) {
        qCInfo(logSetup) << "Existing database found.";
        return DatabaseExists;
    }

    if (!m_databaseManager.initialize(dbPath)) {
        qCCritical(logDatabase) << "Database initialization failed.";

        QFile::remove(dbPath);
        return InitializationFailed;
    }

    m_appService.setDatabasePath(dbPath);

    RegionalSettingsRepository repo(m_databaseManager.db());
    RegionalSettingsService service;

    service.ensureInitialized(repo);

    qCInfo(logApplication) << "System initialization completed successfully.";
    return Success;
}

void SetupService::restartApp()
{
    QString program = QCoreApplication::applicationFilePath();
    QStringList args = QCoreApplication::arguments();

    QProcess::startDetached(program, args);
    QCoreApplication::quit();
}
