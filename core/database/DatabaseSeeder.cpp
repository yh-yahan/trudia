#include "DatabaseSeeder.h"

#include "../logging/LoggingCategories.h"

DatabaseSeeder::DatabaseSeeder(QSqlDatabase db)
    : m_db(db) {}

bool DatabaseSeeder::seed()
{
    return  seedAppState() && seedSettings();
}

bool DatabaseSeeder::seedSettings()
{
    if (!m_db.transaction()) {
        qCWarning(logDatabaseSeeder)
            << "Failed to start seed transaction:"
            << m_db.lastError();

        return false;
    }

    QSqlQuery query(m_db);

    // tax settings
    if (!query.exec(R"(
        INSERT OR IGNORE INTO tax_settings (
            id,
            enabled,
            rate,
            name,
            registration_number
        )
        VALUES (
            1,
            0,
            100,
            '',
            ''
        )
    )")) {
        qCWarning(logDatabaseSeeder)
            << "Failed to seed tax settings:"
            << query.lastError();

        m_db.rollback();
        return false;
    }

    // membership settings
    if (!query.exec(R"(
        INSERT OR IGNORE INTO membership_settings (
            id,
            enabled,
            earn_points,
            earn_spend,
            redeem_points,
            redeem_value,
            earn_on
        )
        VALUES (
            1,
            0,
            1,
            1000,
            100,
            100,
            'total'
        )
    )")) {
        qCWarning(logDatabaseSeeder)
            << "Failed to seed membership settings:"
            << query.lastError();

        m_db.rollback();
        return false;
    }

    // kitchen settings
    if (!query.exec(R"(
        INSERT OR IGNORE INTO kitchen_settings (
            id,
            mode,
            ticket_print_timing,
            require_ready_for_checkout,
            allow_edit_after_send
        )
        VALUES (
            1,
            'none',
            'manual',
            0,
            0
        )
    )")) {
        qCWarning(logDatabaseSeeder)
            << "Failed to seed kitchen settings:"
            << query.lastError();

        m_db.rollback();
        return false;
    }

    // table settings
    if (!query.exec(R"(
        INSERT OR IGNORE INTO table_settings (
            id,
            layout_mode
        )
        VALUES (
            1,
            'simple'
        )
    )")) {
        qCWarning(logDatabaseSeeder)
            << "Failed to seed table settings:"
            << query.lastError();

        m_db.rollback();
        return false;
    }

    if (!m_db.commit()) {
        qCWarning(logDatabaseSeeder)
            << "Failed to commit settings seed:"
            << m_db.lastError();

        m_db.rollback();
        return false;
    }

    return true;
}

bool DatabaseSeeder::seedAppState()
{
    QSqlQuery query(m_db);

        query.prepare(R"(
        INSERT OR IGNORE INTO app_state (key, value)
        VALUES (:key, :value)
    )");

    const QList<QPair<QString, QString>> states = {
        {"app.id", "com.trudia.pos"},
        {"receipt.counter", "0"},
        {"receipt.year", QString::number(QDate::currentDate().year())}
    };

    for (const auto &[key, value] : states)
    {
        query.bindValue(":key", key);
        query.bindValue(":value", value);

        if (!query.exec()) {
            qCWarning(logDatabaseSeeder)
                << "Failed to seed app state:"
                << key
                << query.lastError();

            return false;
        }
    }

    return true;
}
