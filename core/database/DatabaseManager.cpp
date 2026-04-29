#include "DatabaseManager.h"

#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QSqlError>
#include <QSqlQuery>
#include <QDateTime>
#include <QDebug>

namespace
{
    const QString MAIN_CONN = "main_connection";
}

bool DatabaseManager::initialize(const QString &dbPath)
{
    if (QSqlDatabase::contains(MAIN_CONN))
    {
        QSqlDatabase::removeDatabase(MAIN_CONN);
    }

    QSqlDatabase database = QSqlDatabase::addDatabase("QSQLITE", MAIN_CONN);

    // ensure directory exists
    QFileInfo info(dbPath);
    QDir().mkpath(info.absolutePath());

    database.setDatabaseName(dbPath);

    if (!database.open())
    {
        qCritical() << "Cannot open database:" << database.lastError().text();
        return false;
    }

    QSqlQuery q(database);

    if (!q.exec("PRAGMA foreign_keys = ON;"))
    {
        qWarning() << "Failed to enable foreign keys:" << q.lastError().text();
    }

    if (!q.exec("PRAGMA journal_mode = WAL;"))
    {
        qWarning() << "Failed to enable WAL:" << q.lastError().text();
    }
    else
    {
        while (q.next())
        {
        }
        q.finish();
    }

    return runMigrations();
}

bool DatabaseManager::runMigrations()
{
    QSqlDatabase db = QSqlDatabase::database(MAIN_CONN);

    if (!db.isOpen())
    {
        qCritical() << "Database is not open.";
        return false;
    }

    if (!db.transaction())
    {
        qCritical() << "Failed to begin transaction:" << db.lastError().text();
        return false;
    }

    // ensure migrations table exists
    {
        QSqlQuery q(db);
        if (!q.exec(R"(
            CREATE TABLE IF NOT EXISTS applied_migrations (
                migration_name TEXT PRIMARY KEY,
                applied_at TEXT NOT NULL
            )
        )"))
        {
            qCritical() << "Failed to create applied_migrations:" << q.lastError().text();
            db.rollback();
            return false;
        }
    }

    const QStringList migrationFiles = {
        "core/database/migrations/001_create_users.sql",
        "core/database/migrations/002_create_categories.sql",
        "core/database/migrations/003_create_menu.sql",
        "core/database/migrations/004_create_tables.sql",
        "core/database/migrations/005_create_order_sessions.sql",
        "core/database/migrations/006_create_order_items.sql",
        "core/database/migrations/007_create_orders.sql",
        "core/database/migrations/008_create_restaurant.sql",
        "core/database/migrations/009_create_printers.sql",
        "core/database/migrations/010_create_tax_settings.sql",
        "core/database/migrations/011_create_membership_settings.sql",
        "core/database/migrations/012_create_memberships.sql",
        "core/database/migrations/013_create_membership_transactions.sql",
        "core/database/migrations/014_create_kitchen_settings.sql",
        "core/database/migrations/015_create_regional_settings.sql",
    };

    for (const QString &fileName : migrationFiles)
    {
        bool alreadyApplied = false;

        {
            QSqlQuery check(db);
            check.prepare("SELECT 1 FROM applied_migrations WHERE migration_name = ?");
            check.addBindValue(fileName);

            if (!check.exec())
            {
                qCritical() << "Failed to check migration:" << check.lastError().text();
                db.rollback();
                return false;
            }

            alreadyApplied = check.next();
        }

        if (alreadyApplied)
            continue;

        QFile file(":/migrations/" + fileName);
        if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
        {
            qCritical() << "Cannot open migration file:" << fileName;
            db.rollback();
            return false;
        }

        QString sql = QString::fromUtf8(file.readAll());

        QStringList statements = sql.split(';', Qt::SkipEmptyParts);

        for (QString stmt : statements)
        {
            stmt = stmt.trimmed();

            if (stmt.isEmpty())
                continue;

            QSqlQuery q(db);
            if (!q.exec(stmt))
            {
                qCritical() << "Migration failed:" << fileName
                            << "\nStatement:" << stmt
                            << "\nError:" << q.lastError().text();
                db.rollback();
                return false;
            }
        }

        {
            QSqlQuery insert(db);
            insert.prepare(
                "INSERT INTO applied_migrations (migration_name, applied_at) VALUES (?, ?)");
            insert.addBindValue(fileName);
            insert.addBindValue(QDateTime::currentDateTimeUtc().toString(Qt::ISODate));

            if (!insert.exec())
            {
                qCritical() << "Failed to record migration:" << insert.lastError().text();
                db.rollback();
                return false;
            }
        }

        qDebug() << "Migration applied:" << fileName;
    }

    if (!db.commit())
    {
        qCritical() << "Failed to commit transaction:" << db.lastError().text();
        return false;
    }

    return true;
}
bool DatabaseManager::canOpen(const QString &dbPath)
{
    const QString connName = "test_connection";

    if (QSqlDatabase::contains(connName))
    {
        QSqlDatabase::removeDatabase(connName);
    }

    QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE", connName);
    db.setDatabaseName(dbPath);

    bool ok = db.open();
    db.close();

    db = QSqlDatabase();

    QSqlDatabase::removeDatabase(connName);

    return ok;
}

QSqlDatabase DatabaseManager::db()
{
    return QSqlDatabase::database(MAIN_CONN);
}
