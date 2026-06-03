#include "DatabaseService.h"

#include <QFileInfo>
#include <QDir>
#include <QDebug>

DatabaseService::DatabaseService(
    AppService &appService,
    DatabaseManager &databaseManager,
    QObject *parent)
    : QObject(parent),
      m_appService(appService),
      m_databaseManager(databaseManager) {}

bool DatabaseService::moveDatabase(const QString &destinationFolder)
{
    const QString currentPath = m_appService.databasePath();

    if (currentPath.isEmpty())
    {
        qWarning() << "No database configured.";
        return false;
    }

    QFileInfo currentInfo(currentPath);

    if (!currentInfo.exists())
    {
        qWarning() << "Database file does not exist:"
                   << currentPath;
        return false;
    }

    // build: <destinationFolder>/TrudiaPOS/data/<db file>
    const QString appDataDir = QDir(destinationFolder).filePath("TrudiaPOS/data");

    if (!QDir().mkpath(appDataDir))
    {
        qWarning() << "Failed to create destination directory:"
                   << appDataDir;
        return false;
    }

    const QString destinationPath = QDir(appDataDir).filePath(currentInfo.fileName());

    if (destinationPath == currentPath)
    {
        qWarning() << "Source and destination are identical.";
        return false;
    }

    if (QFile::exists(destinationPath))
    {
        qWarning() << "Destination database already exists:"
                   << destinationPath;
        return false;
    }

    qDebug() << "Moving database:";
    qDebug() << "From:" << currentPath;
    qDebug() << "To:" << destinationPath;

    // flush wal contents into main db
    if (!DatabaseManager::checkpoint())
    {
        qWarning() << "Failed to checkpoint database.";
        return false;
    }

    DatabaseManager::close();

    // copy db file
    if (!QFile::copy(currentPath, destinationPath))
    {
        qWarning() << "Failed to copy database:"
                   << currentPath
                   << "->"
                   << destinationPath;

        m_databaseManager.initialize(currentPath);

        return false;
    }

    // verify copied db
    if (!DatabaseManager::canOpen(destinationPath))
    {
        qWarning() << "Copied database could not be opened.";

        QFile::remove(destinationPath);

        m_databaseManager.initialize(currentPath);

        return false;
    }

    // open db from new location
    if (!m_databaseManager.initialize(destinationPath))
    {
        qWarning() << "Failed to initialize moved database.";

        QFile::remove(destinationPath);

        m_databaseManager.initialize(currentPath);

        return false;
    }

    // persist new location
    m_appService.setDatabasePath(destinationPath);

    // cleanup old files
    if (!QFile::remove(currentPath))
    {
        qWarning() << "Failed to delete old database:"
                   << currentPath;
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
            qWarning() << "Failed to remove empty directory:"
                    << trudiaPath;
        }
    }

    qDebug() << "Database moved successfully.";

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
