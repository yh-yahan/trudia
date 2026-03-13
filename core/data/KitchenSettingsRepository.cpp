#include "KitchenSettingsRepository.h"

#include <QSqlQuery>
#include <QSqlError>
#include <QVariant>
#include <QDebug>

KitchenSettingsRepository::KitchenSettingsRepository(QSqlDatabase db): m_db(db) {}

std::optional<KitchenSettings> KitchenSettingsRepository::get()
{
    QSqlQuery query(m_db);
    query.prepare(R"(
        SELECT id, mode, ticket_print_timing, require_ready_for_checkout
        FROM kitchen_settings
        LIMIT 1
    )");

    if (!query.exec()) {
        qWarning() << "Failed to fetch kitchen_settings:"
                   << query.lastError().text();
        return std::nullopt;
    }

    if (!query.next()) {
        return std::nullopt;
    }

    KitchenSettings kitchenSettings;
    kitchenSettings.id = query.value("id").toInt();
    kitchenSettings.mode = query.value("mode").toString();
    kitchenSettings.ticket_print_timing = query.value("ticket_print_timing").toString();
    kitchenSettings.require_ready_for_checkout = query.value("require_ready_for_checkout").toBool();

    return kitchenSettings;
}

void KitchenSettingsRepository::save(const KitchenSettings &kitchenSettings)
{
    QSqlQuery query(m_db);

    query.prepare(R"(
        INSERT INTO kitchen_settings
            (id, mode, ticket_print_timing, require_ready_for_checkout)
        VALUES
            (1, :mode, :ticket_print_timing, :require_ready_for_checkout)
        ON CONFLICT(id) DO UPDATE SET
            mode = excluded.mode,
            ticket_print_timing = excluded.ticket_print_timing,
            require_ready_for_checkout = excluded.require_ready_for_checkout
    )");

    query.bindValue(":mode", kitchenSettings.mode);
    query.bindValue(":ticket_print_timing", kitchenSettings.ticket_print_timing);
    query.bindValue(":require_ready_for_checkout", kitchenSettings.require_ready_for_checkout);

    if (!query.exec()) {
        qWarning() << "Failed to save kitchen_settings:" << query.lastError().text();
    }
}
