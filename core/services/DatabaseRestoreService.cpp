#include "DatabaseRestoreService.h"

#include <QSettings>
#include <QFile>
#include <QFileInfo>
#include <QDir>
#include "../database/DatabaseManager.h"
#include "../logging/LoggingCategories.h"

bool DatabaseRestoreService::processPendingRestore()
{
    QSettings settings;

    // load and check for pending restore
    QString restorePath = settings.value("database/pendingRestore").toString();
    if (restorePath.isEmpty())
        return true;

    QString dbPath = settings.value("database/path").toString();

    // check if live db location is present
    if (dbPath.isEmpty()) return false;

    // validate restore file exists
    QFileInfo restoreInfo(restorePath);
    if (!restoreInfo.exists())
    {
        qCWarning(logDatabase) << "Database restore file does not exist";
        settings.remove("database/pendingRestore");
        return false;
    }

    if (!DatabaseManager::canOpen(restorePath))
    {
        qCWarning(logDatabase) << "Unable to open database file";
        settings.remove("database/pendingRestore");
        return false;
    }

    if (!DatabaseManager::isTrudiaDB(restorePath))
    {
        qCWarning(logDatabase) << "Database is not a Trudia Database";
        settings.remove("database/pendingRestore");
        return false;
    }

    // ensure db dir exists
    QFileInfo dbInfo(dbPath);
    QDir().mkpath(dbInfo.absolutePath());

    // TODO: create backup of current db before deletion

    // delete current db
    QFile::remove(dbPath);
    QFile::remove(dbPath + "-wal");
    QFile::remove(dbPath + "-shm");

    // copy restore file into current db location
    if (!QFile::copy(restorePath, dbPath))
        return false;

    // clear restore path
    settings.remove("database/pendingRestore");

    return true;
}
