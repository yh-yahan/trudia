#include "DatabaseRestoreService.h"

#include <QSettings>
#include <QFile>
#include <QFileInfo>
#include <QDir>
#include <QDateTime>
#include <QSqlDatabase>
#include <QSqlQuery>
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

    // create backup of current db before deletion
    if (dbInfo.exists())
    {
        const QString backupDir = dbInfo.absolutePath() + "/backups";
        if (!QDir().mkpath(backupDir))
        {
            qCWarning(logDatabase) << "Pre-restore backup failed";
            return false;
        }

        const QString backupPath = backupDir + "/" + dbInfo.completeBaseName() + ".pre-restore-" +
            QDateTime::currentDateTime().toString("yyyyMMdd-HHmmss") + ".db";

        bool backedUp = false;
        {
            QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE", "pre-restore-backup");
            db.setDatabaseName(dbPath);
            if (db.open())
            {
                QString escaped = backupPath;
                escaped.replace("'", "''");

                QSqlQuery query(db);
                backedUp = query.exec(QString("VACUUM INTO '%1'").arg(escaped));
                query.finish();
                db.close();
            }
        }
        QSqlDatabase::removeDatabase("pre-restore-backup");

        if (!backedUp)
        {
            qCWarning(logDatabase) << "Pre-restore backup failed";
            return false;
        }
    }

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
