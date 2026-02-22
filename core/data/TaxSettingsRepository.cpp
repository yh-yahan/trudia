#include "TaxSettingsRepository.h"

#include <QSqlQuery>
#include <QSqlError>
#include <QVariant>
#include <QDebug>

TaxSettingsRepository::TaxSettingsRepository(QSqlDatabase db): m_db(db) {}

std::optional<TaxSettings> TaxSettingsRepository::get()
{
    QSqlQuery query(m_db);
    query.prepare(R"(
        SELECT id, enabled, registration_number, price_mode, rounding_strategy, created_at
        FROM tax_settings
        LIMIT 1
    )");

    if (!query.exec()) {
        qWarning() << "Failed to fetch tax_settings:"
                   << query.lastError().text();
        return std::nullopt;
    }

    if (!query.next()) {
        return std::nullopt;
    }

    TaxSettings taxSettings;
    taxSettings.id = query.value("id").toInt();
    taxSettings.enabled = query.value("enabled").toBool();
    taxSettings.price_mode = query.value("price_mode").toString();
    taxSettings.rounding_strategy = query.value("rounding_strategy").toString();
    taxSettings.created_at = query.value("created_at").toString();

    if (!query.value("registration_number").isNull())
        taxSettings.registration_number = query.value("registration_number").toString();

    return taxSettings;
}

void TaxSettingsRepository::save(const TaxSettings &taxSettings)
{
    QSqlQuery query(m_db);

    query.prepare(R"(
        INSERT INTO tax_settings
            (id, enabled, registration_number, price_mode, rounding_strategy)
        VALUES
            (1, :enabled, :registration_number, :price_mode, :rounding_strategy)
        ON CONFLICT(id) DO UPDATE SET
            enabled = excluded.enabled,
            registration_number = excluded.registration_number,
            price_mode = excluded.price_mode,
            rounding_strategy = excluded.rounding_strategy
    )");

    query.bindValue(":enabled", taxSettings.enabled);
    query.bindValue(":price_mode", taxSettings.price_mode);
    query.bindValue(":rounding_strategy", taxSettings.rounding_strategy);

    query.bindValue(":registration_number",
                    taxSettings.registration_number.has_value()
                        ? QVariant(*taxSettings.registration_number)
                        : QVariant());

    if (!query.exec()) {
        qWarning() << "Failed to save tax_settings:" << query.lastError().text();
    }
}
