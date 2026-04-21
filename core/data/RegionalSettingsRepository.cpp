#include "RegionalSettingsRepository.h"

#include <QSqlQuery>
#include <QSqlError>
#include <QVariant>
#include <QDebug>

RegionalSettingsRepository::RegionalSettingsRepository(QSqlDatabase db): m_db(db) {}

std::optional<RegionalSettings> RegionalSettingsRepository::get()
{
    QSqlQuery query(m_db);
    query.prepare("SELECT id, locale, currency_code, "
                  "timezone, date_format, time_format "
                  "FROM regional_settings");

    if (!query.exec()) {
        qDebug() << "Failed to fetch regional setting:" << query.lastError().text();
        return std::nullopt;
    }

    if (!query.next()) {
        return std::nullopt;
    }

    RegionalSettings setting;

    setting.id = query.value("id").toInt();
    setting.locale = query.value("locale").toString();
    setting.currency_code = query.value("currency_code").toString();
    setting.timezone = query.value("timezone").toString();
    setting.date_format = query.value("date_format").toString();
    setting.time_format = query.value("time_format").toString();

    return setting;
}

void RegionalSettingsRepository::save(const RegionalSettings &setting)
{
    auto existing = get();

    QSqlQuery query(m_db);

    query.prepare(R"(
        INSERT INTO regional_settings
            (id, locale, currency_code, timezone, date_format, time_format)
        VALUES
            (1, :locale, :currency_code, :timezone, :date_format, :time_format)
        ON CONFLICT(id) DO UPDATE SET
            locale = excluded.locale,
            currency_code = excluded.currency_code,
            timezone = excluded.timezone,
            date_format = excluded.date_format,
            time_format = excluded.time_format
    )");

    query.bindValue(":locale", setting.locale);
    query.bindValue(":currency_code", setting.currency_code);
    query.bindValue(":timezone", setting.timezone);
    query.bindValue(":date_format", setting.date_format);
    query.bindValue(":time_format", setting.time_format);

    if (!query.exec()) {
        qDebug() << "Failed to save regional setting:" << query.lastError().text();
    }
}
