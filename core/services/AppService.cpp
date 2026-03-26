#include "AppService.h"

#include <QSettings>
#include <QFile>
#include <QDebug>
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
        qDebug() << "No DB path configured";
        return NeedsSetup;
    }

    QString path = databasePath();

    if (!QFile::exists(path)) {
        qDebug() << "DB file missing";
        return NeedsSetup;
    }

    if (!DatabaseManager::canOpen(path)) {
        qDebug() << "DB cannot be opened";
        return NeedsSetup;
    }

    if (!hasAnyUser()) {
        qDebug() << "No users found";
        return NeedsAdminSetup;
    }

    return Ready;
}

bool AppService::hasAnyUser() const
{
    QString path = databasePath();

    const QString connName = "check_users";

    if (QSqlDatabase::contains(connName)) {
        QSqlDatabase::removeDatabase(connName);
    }

    QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE", connName);
    db.setDatabaseName(path);

    if (!db.open()) {
        return false;
    }

    QSqlQuery q(db);

    bool hasUser = false;

    if (q.exec("SELECT 1 FROM users LIMIT 1")) {
        hasUser = q.next();
    }

    db.close();
    QSqlDatabase::removeDatabase(connName);

    return hasUser;
}
