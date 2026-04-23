#include "RegionalSettingsRepository.h"

#include <QSqlQuery>
#include <QSqlError>
#include <QVariant>
#include <QDebug>

RegionalSettingsRepository::RegionalSettingsRepository(QSqlDatabase db): m_db(db) {}

std::optional<RegionalSettings> RegionalSettingsRepository::get()
{
    QSqlQuery query(m_db);
    query.prepare("SELECT id, locale, currency_code "
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

    return setting;
}

void RegionalSettingsRepository::save(const RegionalSettings &setting)
{
    QSqlQuery query(m_db);

    query.prepare(R"(
        INSERT INTO regional_settings
            (id, locale, currency_code)
        VALUES
            (1, :locale, :currency_code)
        ON CONFLICT(id) DO UPDATE SET
            locale = excluded.locale,
            currency_code = excluded.currency_code
    )");

    query.bindValue(":locale", setting.locale);
    query.bindValue(":currency_code", setting.currency_code);

    if (!query.exec()) {
        qDebug() << "Failed to save regional setting:" << query.lastError().text();
    }
}
