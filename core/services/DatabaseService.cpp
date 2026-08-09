#include "DatabaseService.h"

#include <QFileInfo>
#include <QDir>
#include <QSettings>
#include "../logging/LoggingCategories.h"

DatabaseService::DatabaseService(
    AppService &appService,
    DatabaseManager &databaseManager,
    QObject *parent)
    : QObject(parent),
      m_appService(appService),
      m_databaseManager(databaseManager) {}

bool DatabaseService::backupDatabase()
{
    QFileInfo dbInfo(m_appService.databasePath());

    if (!dbInfo.exists())
    {
        qCWarning(logDatabase) << "Database file does not exist:" << dbInfo.absoluteFilePath();
        return false;
    }

    QString backupDir = dbInfo.absolutePath() + "/backups";

    if (!QDir().mkpath(backupDir))
    {
        qCWarning(logDatabase) << "Failed to create backup directory.";
        return false;
    }

    QString timestamp = QDateTime::currentDateTime().toString("yyyy-MM-dd_hh-mm-ss");

    QString backupPath = backupDir + QString("/backup_%1.db").arg(timestamp);

    QSqlDatabase db = m_databaseManager.db();

    if (!db.isOpen())
    {
        qCWarning(logDatabase) << "Database is not open.";
        return false;
    }

    // flush WAL to main db before backup
    if (!DatabaseManager::checkpoint())
    {
        qCWarning(logDatabase) << "Failed to checkpoint database before backup.";
        return false;
    }

    QString escapedPath = backupPath;
    escapedPath.replace("'", "''");

    QSqlQuery query(db);

    QString sql = QString("VACUUM INTO '%1'").arg(escapedPath);

    qCInfo(logDatabase) << "Creating backup with SQL.";

    if (!query.exec(sql))
    {
        qCWarning(logDatabase) << "Backup failed:" << query.lastError().text();
        return false;
    }

    return true;
}

// requires app to restart
bool DatabaseService::restoreDatabase(const QString &dbFilePath) {
    QFileInfo dbInfo(dbFilePath);

    if (!dbInfo.exists())
    {
        qCWarning(logDatabase) << "Database file does not exist";
        return false;
    }

    QSettings settings;
    settings.setValue("database/pendingRestore", dbFilePath);

    return true;
}

// requires app to restart
bool DatabaseService::moveDatabase(const QString &destinationFolder)
{
    const QString currentPath = m_appService.databasePath();

    if (currentPath.isEmpty())
    {
        qCWarning(logDatabase) << "No database configured.";
        return false;
    }

    QFileInfo currentInfo(currentPath);

    if (!currentInfo.exists())
    {
        qCWarning(logDatabase) << "Database file does not exist.";
        return false;
    }

    // build: <destinationFolder>/TrudiaPOS/data/<db file>
    const QString appDataDir = QDir(destinationFolder).filePath("TrudiaPOS/data");

    if (!QDir().mkpath(appDataDir))
    {
        qCWarning(logDatabase) << "Failed to create destination directory.";
        return false;
    }

    const QString destinationPath = QDir(appDataDir).filePath(currentInfo.fileName());

    if (destinationPath == currentPath)
    {
        qCWarning(logDatabase) << "Source and destination are identical.";
        return false;
    }

    if (QFile::exists(destinationPath))
    {
        qCWarning(logDatabase) << "Destination database already exists.";
        return false;
    }

    // flush wal contents into main db
    if (!DatabaseManager::checkpoint())
    {
        qCWarning(logDatabase) << "Failed to checkpoint database.";
        return false;
    }

    DatabaseManager::close();

    // copy db file
    if (!QFile::copy(currentPath, destinationPath))
    {
        qCWarning(logDatabase) << "Failed to copy database.";

        m_databaseManager.initialize(currentPath);

        return false;
    }

    // verify copied db
    if (!DatabaseManager::canOpen(destinationPath))
    {
        qCWarning(logDatabase) << "Copied database could not be opened.";

        QFile::remove(destinationPath);

        m_databaseManager.initialize(currentPath);

        return false;
    }

    // open db from new location
    if (!m_databaseManager.initialize(destinationPath))
    {
        qCWarning(logDatabase) << "Failed to initialize moved database.";

        QFile::remove(destinationPath);

        m_databaseManager.initialize(currentPath);

        return false;
    }

    // persist new location
    m_appService.setDatabasePath(destinationPath);

    // cleanup old files
    if (!QFile::remove(currentPath))
    {
        qCWarning(logDatabase) << "Failed to delete old database.";
    }

    QFile::remove(currentPath + "-wal");
    QFile::remove(currentPath + "-shm");

    QDir trudiaDir(QFileInfo(currentPath).dir().absolutePath());

    trudiaDir.cdUp();

    const QString trudiaPath = trudiaDir.absolutePath();

    if (!directoryContainsFilesRecursively(trudiaPath))
    {
        if (!QDir(trudiaPath).removeRecursively())
        {
            qCWarning(logDatabase) << "Failed to remove empty directory.";
        }
    }

    qCInfo(logDatabase) << "Database moved successfully.";

    return true;
}

// requires app to restart
bool DatabaseService::openDatabase(const QString &dbFilePath)
{
    QFileInfo dbInfo(dbFilePath);

    if (!dbInfo.exists() || !dbInfo.isFile())
    {
        qCWarning(logDatabase)
            << "Database file does not exist:"
            << dbFilePath;
        return false;
    }

    if (!DatabaseManager::canOpen(dbFilePath))
    {
        qCWarning(logDatabase)
            << "Database cannot be opened:"
            << dbFilePath;
        return false;
    }

    m_appService.setDatabasePath(dbFilePath);

    qCInfo(logDatabase) << "Database selected successfully.";

    return true;
}

bool DatabaseService::directoryContainsFilesRecursively(const QString &path)
{
    QDir dir(path);

    QFileInfoList entries = dir.entryInfoList(QDir::NoDotAndDotDot | QDir::AllEntries);

    for (const QFileInfo &entry : entries)
    {
        if (entry.isFile())
        {
            return true;
        }

        if (entry.isDir())
        {
            if (directoryContainsFilesRecursively(entry.absoluteFilePath()))
            {
                return true;
            }
        }
    }

    return false;
}
