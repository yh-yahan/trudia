#include "SetupService.h"

#include <QFile>
#include <QDebug>
#include "../data/RegionalSettingsRepository.h"
#include "./RegionalSettingsService.h"

SetupService::SetupService(AppService &appService,
                           DatabaseManager &databaseManager,
                           QObject *parent)
    : QObject(parent),
      m_appService(appService),
      m_databaseManager(databaseManager) {}

bool SetupService::initializeSystem(const QString &dbPath)
{
    qDebug() << "Starting system initialization...";

    if (dbPath.isEmpty()) {
        qWarning() << "Invalid setup input.";
        return false;
    }

    if (QFile::exists(dbPath)) {
        qWarning() << "Existing database found. Removing...";
        if (!QFile::remove(dbPath)) {
            qCritical() << "Failed to remove existing database file.";
            return false;
        }
    }

    if (!m_databaseManager.initialize(dbPath)) {
        qCritical() << "Database initialization failed.";

        QFile::remove(dbPath);
        return false;
    }

    m_appService.setDatabasePath(dbPath);

    RegionalSettingsRepository repo(m_databaseManager.db());
    RegionalSettingsService service;

    service.ensureInitialized(repo);

    qDebug() << "System initialization completed successfully.";
    return true;
}

void SetupService::restartApp()
{
    QString program = QCoreApplication::applicationFilePath();
    QStringList args = QCoreApplication::arguments();

    QProcess::startDetached(program, args);
    QCoreApplication::quit();
}
