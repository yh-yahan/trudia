#include "TaxSettingsRepository.h"

#include <QSqlQuery>
#include <QSqlError>
#include <QVariant>
#include "../logging/LoggingCategories.h"

TaxSettingsRepository::TaxSettingsRepository(QSqlDatabase db): m_db(db) {}

std::optional<TaxSettings> TaxSettingsRepository::get()
{
    QSqlQuery query(m_db);
    query.prepare(R"(
        SELECT id, enabled, rate, registration_number, name, created_at
        FROM tax_settings
        LIMIT 1
    )");

    if (!query.exec()) {
        qCWarning(logDatabase) << "Failed to fetch tax_settings:"
                   << query.lastError().text();
        return std::nullopt;
    }

    if (!query.next()) {
        return std::nullopt;
    }

    TaxSettings taxSettings;
    taxSettings.id = query.value("id").toInt();
    taxSettings.enabled = query.value("enabled").toBool();
    taxSettings.rate = query.value("rate").toInt();
    taxSettings.name = query.value("name").toString();
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
            (id, enabled, rate, registration_number, name)
        VALUES
            (1, :enabled, :rate, :registration_number, :name)
        ON CONFLICT(id) DO UPDATE SET
            enabled = excluded.enabled,
            rate = excluded.rate,
            registration_number = excluded.registration_number,
            name = excluded.name
    )");

    query.bindValue(":enabled", taxSettings.enabled);
    query.bindValue(":rate", taxSettings.rate);
    query.bindValue(":name", taxSettings.name);

    query.bindValue(":registration_number",
                    taxSettings.registration_number.has_value()
                        ? QVariant(*taxSettings.registration_number)
                        : QVariant());

    if (!query.exec()) {
        qCWarning(logDatabase) << "Failed to save tax_settings:" << query.lastError().text();
    }
}
