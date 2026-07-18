#include "MembershipSettingsRepository.h"

#include <QSqlQuery>
#include <QSqlError>
#include <QVariant>
#include "../logging/LoggingCategories.h"

MembershipSettingsRepository::MembershipSettingsRepository(QSqlDatabase db) : m_db(db) {}

std::optional<MembershipSettings> MembershipSettingsRepository::get()
{
    QSqlQuery query(m_db);
    query.prepare(R"(
        SELECT id, enabled,
            earn_points, earn_spend,
            redeem_points, redeem_value,
            earn_on, created_at
        FROM membership_settings
        LIMIT 1
    )");

    if (!query.exec())
    {
        qCWarning(logDatabase) << "Failed to fetch membership_settings:"
                   << query.lastError().text();
        return std::nullopt;
    }

    if (!query.next())
    {
        return std::nullopt;
    }

    MembershipSettings membershipSettings;
    membershipSettings.id = query.value("id").toInt();
    membershipSettings.enabled = query.value("enabled").toBool();
    membershipSettings.earn_points = query.value("earn_points").toInt();
    membershipSettings.earn_spend = query.value("earn_spend").toInt();
    membershipSettings.redeem_points = query.value("redeem_points").toInt();
    membershipSettings.redeem_value = query.value("redeem_value").toInt();
    membershipSettings.earn_on = query.value("earn_on").toString();

    return membershipSettings;
}

void MembershipSettingsRepository::save(const MembershipSettings &membershipSettings)
{
    QSqlQuery query(m_db);

    query.prepare(R"(
        INSERT INTO membership_settings
            (id, enabled,
            earn_points, earn_spend,
            redeem_points, redeem_value,
            earn_on)
        VALUES
            (1, :enabled,
            :earn_points, :earn_spend,
            :redeem_points, :redeem_value,
            :earn_on)
        ON CONFLICT(id) DO UPDATE SET
            enabled = excluded.enabled,
            earn_points = excluded.earn_points,
            earn_spend = excluded.earn_spend,
            redeem_points = excluded.redeem_points,
            redeem_value = excluded.redeem_value,
            earn_on = excluded.earn_on
    )");

    query.bindValue(":enabled", membershipSettings.enabled);
    query.bindValue(":earn_points", membershipSettings.earn_points);
    query.bindValue(":earn_spend", membershipSettings.earn_spend);
    query.bindValue(":redeem_points", membershipSettings.redeem_points);
    query.bindValue(":redeem_value", membershipSettings.redeem_value);
    query.bindValue(":earn_on", membershipSettings.earn_on);

    if (!query.exec())
    {
        qCWarning(logDatabase) << "Failed to save membership_settings:" << query.lastError().text();
    }
}
