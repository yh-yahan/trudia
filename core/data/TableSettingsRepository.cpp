#include "TableSettingsRepository.h"

#include <QSqlQuery>
#include <QSqlError>
#include <QVariant>
#include <QDebug>

TableSettingsRepository::TableSettingsRepository(QSqlDatabase db): m_db(db) {}

std::optional<TableSettings> TableSettingsRepository::get()
{
    QSqlQuery query(m_db);
    query.prepare(R"(
        SELECT id, layout_mode
        FROM table_settings
        LIMIT 1
    )");

    if (!query.exec()) {
        qWarning() << "Failed to fetch table_settings:"
                   << query.lastError().text();
        return std::nullopt;
    }

    if (!query.next()) {
        return std::nullopt;
    }

    TableSettings tableSettings;
    tableSettings.id = query.value("id").toInt();
    tableSettings.layout_mode = query.value("layout_mode").toString();

    return tableSettings;
}

void TableSettingsRepository::save(const TableSettings &tableSettings)
{
    QSqlQuery query(m_db);

    query.prepare(R"(
        INSERT INTO table_settings
            (id, layout_mode)
        VALUES
            (1, :layout_mode)
        ON CONFLICT(id) DO UPDATE SET
            layout_mode = excluded.layout_mode
    )");

    query.bindValue(":layout_mode", tableSettings.layout_mode);

    if (!query.exec()) {
        qWarning() << "Failed to save table_settings:" << query.lastError().text();
    }
}
