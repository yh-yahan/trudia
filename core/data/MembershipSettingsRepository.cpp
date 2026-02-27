#include "MembershipSettingsRepository.h"

#include <QSqlQuery>
#include <QSqlError>
#include <QVariant>
#include <QDebug>

MembershipSettingsRepository::MembershipSettingsRepository(QSqlDatabase db): m_db(db) {}

std::optional<MembershipSettings> MembershipSettingsRepository::get()
{
    QSqlQuery query(m_db);
    query.prepare(R"(
        SELECT id, enabled, earn_rate, min_spend, earn_on, conversion, redeem_min_point, partial_redemption, created_at
        FROM membership_settings
        LIMIT 1
    )");

    if (!query.exec()) {
        qWarning() << "Failed to fetch membership_settings:"
                   << query.lastError().text();
        return std::nullopt;
    }

    if (!query.next()) {
        return std::nullopt;
    }

    MembershipSettings membershipSettings;
    membershipSettings.id = query.value("id").toInt();
    membershipSettings.enabled = query.value("enabled").toBool();
    membershipSettings.earn_rate = query.value("earn_rate").toInt();
    membershipSettings.min_spend = query.value("min_spend").toInt();
    membershipSettings.earn_on = query.value("earn_on").toString();
    membershipSettings.conversion = query.value("conversion").toInt();
    membershipSettings.redeem_min_point = query.value("redeem_min_point").toInt();
    membershipSettings.partial_redemption = query.value("partial_redemption").toInt();
    membershipSettings.created_at = query.value("created_at").toString();

    return membershipSettings;
}

void MembershipSettingsRepository::save(const MembershipSettings &membershipSettings)
{
    QSqlQuery query(m_db);

    query.prepare(R"(
        INSERT INTO membership_settings
            (id, enabled, earn_rate, min_spend, earn_on, conversion, redeem_min_point, partial_redemption)
        VALUES
            (1, :enabled, :earn_rate, :min_spend, :earn_on, :conversion, :redeem_min_point, :partial_redemption)
        ON CONFLICT(id) DO UPDATE SET
            enabled = excluded.enabled,
            earn_rate = excluded.earn_rate,
            min_spend = excluded.min_spend,
            earn_on = excluded.earn_on,
            conversion = excluded.conversion,
            redeem_min_point = excluded.redeem_min_point,
            partial_redemption = excluded.partial_redemption
    )");

    query.bindValue(":enabled", membershipSettings.enabled);
    query.bindValue(":earn_rate", membershipSettings.earn_rate);
    query.bindValue(":min_spend", membershipSettings.min_spend);
    query.bindValue(":earn_on", membershipSettings.earn_on);
    query.bindValue(":conversion", membershipSettings.conversion);
    query.bindValue(":redeem_min_point", membershipSettings.redeem_min_point);
    query.bindValue(":partial_redemption", membershipSettings.partial_redemption);

    if (!query.exec()) {
        qWarning() << "Failed to save membership_settings:" << query.lastError().text();
    }
}
