#include "DatabaseManager.h"

#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QSqlError>
#include <QSqlQuery>
#include <QDateTime>
#include <QCoreApplication>
#include "../logging/LoggingCategories.h"

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
        qCCritical(logDatabase) << "Cannot open database:" << database.lastError().text();
        return false;
    }

    QSqlQuery q(database);

    if (!q.exec("PRAGMA foreign_keys = ON;"))
    {
        qCWarning(logDatabase) << "Failed to enable foreign keys:" << q.lastError().text();
    }

    if (!q.exec("PRAGMA journal_mode = WAL;"))
    {
        qCWarning(logDatabase) << "Failed to enable WAL:" << q.lastError().text();
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
        qCCritical(logDatabase) << "Database is not open.";
        return false;
    }

    if (!db.transaction())
    {
        qCCritical(logDatabase) << "Failed to begin transaction:" << db.lastError().text();
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
            qCCritical(logMigration) << "Failed to create applied_migrations:" << q.lastError().text();
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
        "core/database/migrations/016_create_floors.sql",
        "core/database/migrations/017_create_canvas_items.sql",
        "core/database/migrations/018_create_table_settings.sql",
        "core/database/migrations/019_create_reservations.sql",
        "core/database/migrations/020_create_app_state.sql",
        "core/database/migrations/021_create_receipt_snapshot.sql",
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
                qCCritical(logMigration) << "Failed to check migration:" << check.lastError().text();
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
            QDir dir(QCoreApplication::applicationDirPath());
            dir.cdUp();
            dir.cdUp();

            QString fsPath = dir.absoluteFilePath("core/database/migrations/" + fileName.split('/').last());

            file.setFileName(fsPath);

            if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
            {
                qCCritical(logMigration) << "Cannot open migration file:" << fileName << "Tried:" << fsPath;
                db.rollback();
                return false;
            }
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
                qCCritical(logMigration) << "Migration failed:" << fileName
                            << "\nStatement:" << stmt
                            << "\nError:" << q.lastError().text();
                db.rollback();
                return false;
            }
        }

        {
            QSqlQuery insert(db);
            insert.prepare("INSERT INTO applied_migrations (migration_name, applied_at) VALUES (?, ?)");
            insert.addBindValue(fileName);
            insert.addBindValue(QDateTime::currentDateTimeUtc().toString(Qt::ISODate));

            if (!insert.exec())
            {
                qCCritical(logMigration) << "Failed to record migration:" << insert.lastError().text();
                db.rollback();
                return false;
            }
        }

        qCInfo(logMigration) << "Migration applied:" << fileName;
    }

    if (!db.commit())
    {
        qCCritical(logDatabase) << "Failed to commit transaction:" << db.lastError().text();
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

    if (!ok)
    {
        qCWarning(logDatabase)
            << "Failed to open database test connection:"
            << dbPath
            << db.lastError().text();
    }

    db.close();

    db = QSqlDatabase();

    QSqlDatabase::removeDatabase(connName);

    return ok;
}

bool DatabaseManager::isOpen()
{
    return QSqlDatabase::contains(MAIN_CONN) && QSqlDatabase::database(MAIN_CONN).isOpen();
}

bool DatabaseManager::checkpoint()
{
    if (!QSqlDatabase::contains(MAIN_CONN))
    {
        return false;
    }

    QSqlDatabase database = QSqlDatabase::database(MAIN_CONN);

    if (!database.isOpen())
    {
        return false;
    }

    QSqlQuery q(database);

    if (!q.exec("PRAGMA wal_checkpoint(FULL);"))
    {
        qCWarning(logDatabase) << "Failed to checkpoint WAL:" << q.lastError().text();
        return false;
    }

    return true;
}

void DatabaseManager::close()
{
    if (!QSqlDatabase::contains(MAIN_CONN))
    {
        return;
    }

    {
        QSqlDatabase database = QSqlDatabase::database(MAIN_CONN);

        if (database.isOpen())
        {
            database.close();
        }
    }

    QSqlDatabase::removeDatabase(MAIN_CONN);

    qCInfo(logDatabase) << "Database closed";
}

bool DatabaseManager::beginTransaction()
{
    if (!QSqlDatabase::contains(MAIN_CONN))
    {
        qCWarning(logDatabase) << "Cannot begin transaction: database connection does not exist.";
        return false;
    }

    QSqlDatabase database = QSqlDatabase::database(MAIN_CONN);

    if (!database.isOpen())
    {
        qCWarning(logDatabase) << "Cannot begin transaction: database is not open.";
        return false;
    }

    if (database.transaction())
    {
        return true;
    }

    qCWarning(logDatabase) << "Failed to begin transaction:"
               << database.lastError().text();

    return false;
}

bool DatabaseManager::commit()
{
    if (!QSqlDatabase::contains(MAIN_CONN))
    {
        qCWarning(logDatabase) << "Cannot commit: database connection does not exist.";
        return false;
    }

    QSqlDatabase database = QSqlDatabase::database(MAIN_CONN);

    if (!database.isOpen())
    {
        qCWarning(logDatabase) << "Cannot commit: database is not open.";
        return false;
    }

    if (database.commit())
    {
        return true;
    }

    qCWarning(logDatabase) << "Failed to commit transaction:"
               << database.lastError().text();

    return false;
}

bool DatabaseManager::rollback()
{
    if (!QSqlDatabase::contains(MAIN_CONN))
    {
        qCWarning(logDatabase) << "Cannot rollback: database connection does not exist.";
        return false;
    }

    QSqlDatabase database = QSqlDatabase::database(MAIN_CONN);

    if (!database.isOpen())
    {
        qCWarning(logDatabase) << "Cannot rollback: database is not open.";
        return false;
    }

    if (database.rollback())
    {
        return true;
    }

    qCWarning(logDatabase) << "Failed to rollback transaction:"
               << database.lastError().text();

    return false;
}

QSqlDatabase DatabaseManager::db()
{
    return QSqlDatabase::database(MAIN_CONN);
}
