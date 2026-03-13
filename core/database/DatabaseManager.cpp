#include "DatabaseManager.h"
#include <QStandardPaths>
#include <QDir>
#include <QDebug>

bool DatabaseManager::initialize()
{
    QString path = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir().mkpath(path);

    QString dbPath = path + "/xeno.db";

    QSqlDatabase database = QSqlDatabase::addDatabase("QSQLITE");
    database.setDatabaseName(dbPath);

    if (!database.open()) {
        qCritical() << "Cannot open database:" << database.lastError().text();

        return false;
    }

    QSqlQuery q;
    q.exec("PRAGMA foreign_keys = ON;");
    q.exec("PRAGMA journal_mode = WAL;");
    while (q.next()) {}
    q.finish();

    return runMigrations();
}

bool DatabaseManager::runMigrations()
{
    QSqlDatabase db = QSqlDatabase::database();

    if (!db.transaction()) {
        qCritical() << "Failed to begin transaction:" << db.lastError().text();
        return false;
    }

    {
        QSqlQuery q;
        if (!q.exec(R"(
            CREATE TABLE IF NOT EXISTS applied_migrations (
                migration_name TEXT PRIMARY KEY,
                applied_at TEXT NOT NULL
            )
        )")) {
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
        "core/database/migrations/009_create_printer_settings.sql",
        "core/database/migrations/010_create_tax_settings.sql",
        "core/database/migrations/011_create_membership_settings.sql",
        "core/database/migrations/012_create_memberships.sql",
        "core/database/migrations/013_create_membership_transactions.sql",
        "core/database/migrations/014_create_kitchen_settings.sql",
    };

    for (const QString &fileName : migrationFiles) {
        {
            QSqlQuery check;
            check.prepare("SELECT 1 FROM applied_migrations WHERE migration_name = ?");
            check.addBindValue(fileName);

            if (!check.exec()) {
                qCritical() << "Failed to check migration:" << check.lastError().text();
                db.rollback();
                return false;
            }

            if (check.next()) continue;
        }

        QFile file(QString(":/migrations/" + fileName));
        if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
            qCritical() << "Cannot open migration file:" << fileName;
            db.rollback();
            return false;
        }

        QString sql = QString::fromUtf8(file.readAll());

        QSqlQuery migrate;
        if (!migrate.exec(sql)) {
            qCritical() << "Migration failed:" << fileName << migrate.lastError().text();
            db.rollback();
            return false;
        }

        QSqlQuery insert;
        insert.prepare(
            "INSERT INTO applied_migrations (migration_name, applied_at) VALUES (?, ?)"
        );
        insert.addBindValue(fileName);
        insert.addBindValue(QDateTime::currentDateTimeUtc().toString(Qt::ISODate));

        if (!insert.exec()) {
            qCritical() << "Failed to record migration:" << insert.lastError().text();
            db.rollback();
            return false;
        }

        qDebug() << "Migration applied:" << fileName;
    }

    if (!db.commit()) {
        qCritical() << "Failed to commit transaction:" << db.lastError().text();
        return false;
    }

    return true;
}

QSqlDatabase DatabaseManager::db()
{
    return QSqlDatabase::database();
}
