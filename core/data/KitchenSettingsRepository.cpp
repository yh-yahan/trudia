#include "KitchenSettingsRepository.h"

#include <QSqlQuery>
#include <QSqlError>
#include <QVariant>
#include "../logging/LoggingCategories.h"

KitchenSettingsRepository::KitchenSettingsRepository(QSqlDatabase db): m_db(db) {}

std::optional<KitchenSettings> KitchenSettingsRepository::get()
{
    QSqlQuery query(m_db);
    query.prepare(R"(
        SELECT id, mode, ticket_print_timing, require_ready_for_checkout, allow_edit_after_send
        FROM kitchen_settings
        LIMIT 1
    )");

    if (!query.exec()) {
        qCWarning(logDatabase) << "Failed to fetch kitchen_settings:"
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
    kitchenSettings.allow_edit_after_send = query.value("allow_edit_after_send").toBool();

    return kitchenSettings;
}

void KitchenSettingsRepository::save(const KitchenSettings &kitchenSettings)
{
    QSqlQuery query(m_db);

    query.prepare(R"(
        INSERT INTO kitchen_settings
            (id, mode, ticket_print_timing, require_ready_for_checkout, allow_edit_after_send)
        VALUES
            (1, :mode, :ticket_print_timing, :require_ready_for_checkout, :allow_edit_after_send)
        ON CONFLICT(id) DO UPDATE SET
            mode = excluded.mode,
            ticket_print_timing = excluded.ticket_print_timing,
            require_ready_for_checkout = excluded.require_ready_for_checkout,
            allow_edit_after_send = excluded.allow_edit_after_send
    )");

    query.bindValue(":mode", kitchenSettings.mode);
    query.bindValue(":ticket_print_timing", kitchenSettings.ticket_print_timing);
    query.bindValue(":require_ready_for_checkout", kitchenSettings.require_ready_for_checkout);
    query.bindValue(":allow_edit_after_send", kitchenSettings.allow_edit_after_send);

    if (!query.exec()) {
        qCWarning(logDatabase) << "Failed to save kitchen_settings:" << query.lastError().text();
    }
}
