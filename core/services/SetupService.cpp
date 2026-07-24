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

bool SetupService::initializeSystem(const QString &dbPath)
{
    qCInfo(logApplication) << "Starting system initialization...";

    if (dbPath.isEmpty()) {
        qCWarning(logSetup) << "Invalid setup input.";
        return false;
    }

    if (QFile::exists(dbPath)) {
        qCWarning(logSetup) << "Existing database found. Removing...";
        if (!QFile::remove(dbPath)) {
            qCritical() << "Failed to remove existing database file.";
            return false;
        }
    }

    if (!m_databaseManager.initialize(dbPath)) {
        qCCritical(logDatabase) << "Database initialization failed.";

        QFile::remove(dbPath);
        return false;
    }

    m_appService.setDatabasePath(dbPath);

    RegionalSettingsRepository repo(m_databaseManager.db());
    RegionalSettingsService service;

    service.ensureInitialized(repo);

    qCInfo(logApplication) << "System initialization completed successfully.";
    return true;
}

void SetupService::restartApp()
{
    QString program = QCoreApplication::applicationFilePath();
    QStringList args = QCoreApplication::arguments();

    QProcess::startDetached(program, args);
    QCoreApplication::quit();
}
