#include "AppService.h"

#include <QSettings>
#include <QFile>
#include "../logging/LoggingCategories.h"
#include "../database/DatabaseManager.h"

AppService::AppService(QObject *parent)
    : QObject(parent) {}

QString AppService::databasePath() const
{
    QSettings settings;
    return settings.value(m_dbPathKey).toString();
}

void AppService::setDatabasePath(const QString &path)
{
    QSettings settings;
    settings.setValue(m_dbPathKey, path);
}

bool AppService::hasDatabasePath() const
{
    QSettings settings;
    return settings.contains(m_dbPathKey) && !databasePath().isEmpty();
}

AppService::AppState AppService::determineState() const
{
    if (!hasDatabasePath()) {
        qCInfo(logApplication) << "No DB path configured";
        return NeedsSetup;
    }

    QString path = databasePath();

    if (!QFile::exists(path)) {
        qCWarning(logApplication) << "DB file not found";
        return NeedsSetup;
    }

    if (!DatabaseManager::canOpen(path)) {
        qCWarning(logApplication) << "DB cannot be opened";
        return NeedsSetup;
    }

    if (!hasAdminUser()) {
        qCInfo(logApplication) << "No admin user found";
        return NeedsAdminSetup;
    }

    return Ready;
}

bool AppService::hasAdminUser() const
{
    const QString connName = "check_users";

    if (QSqlDatabase::contains(connName)) {
        QSqlDatabase::removeDatabase(connName);
    }

    bool hasAdmin = false;

    {
        QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE", connName);
        db.setDatabaseName(databasePath());

        if (!db.open()) {
            return false;
        }

        {
            QSqlQuery q(db);

            if (q.exec("SELECT 1 FROM users WHERE role = 'admin' AND deactivated_at IS NULL LIMIT 1")) 
                hasAdmin = q.next();
        }

        db.close();
    }

    QSqlDatabase::removeDatabase(connName);

    return hasAdmin;
}
