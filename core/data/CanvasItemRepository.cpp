#include "CanvasItemRepository.h"

#include <QSqlQuery>
#include <QSqlError>
#include <QVariant>
#include "../logging/LoggingCategories.h"

CanvasItemRepository::CanvasItemRepository(QSqlDatabase db)
    : m_db(db) {}

std::vector<CanvasItem> CanvasItemRepository::getByFloorId(int floorId)
{
    std::vector<CanvasItem> items;

    QSqlQuery query(m_db);

    query.prepare(R"(
        SELECT *
        FROM canvas_items
        WHERE floor_id = :floor_id
        ORDER BY z_order ASC
    )");

    query.bindValue(":floor_id", floorId);

    if (!query.exec()) {
        qCWarning(logDatabase) << "Failed to fetch canvas items:"
                   << query.lastError();

        return items;
    }

    while (query.next()) {
        CanvasItem item;

        item.id = query.value("id").toInt();
        item.floor_id = query.value("floor_id").toInt();

        if (!query.value("table_id").isNull())
            item.table_id = query.value("table_id").toInt();

        item.type = query.value("type").toString();

        if (!query.value("label").isNull())
            item.label = query.value("label").toString();

        item.x = query.value("x").toDouble();
        item.y = query.value("y").toDouble();
        item.width = query.value("width").toDouble();
        item.height = query.value("height").toDouble();
        item.rotation = query.value("rotation").toDouble();

        item.color = query.value("color").toString();
        item.border_color = query.value("border_color").toString();
        item.border_width = query.value("border_width").toDouble();
        item.opacity = query.value("opacity").toDouble();
        item.z_order = query.value("z_order").toInt();

        if (!query.value("metadata").isNull())
            item.metadata = query.value("metadata").toString();

        items.push_back(item);
    }

    return items;
}

bool CanvasItemRepository::saveAll(
    int floorId,
    const std::vector<CanvasItem>& items)
{
    if (!m_db.transaction()) {
        qCWarning(logDatabase) << "Failed to begin transaction for saveAll";
        return false;
    }

    QSqlQuery deleteQuery(m_db);

    deleteQuery.prepare(R"(
        DELETE FROM canvas_items
        WHERE floor_id = :floor_id
    )");

    deleteQuery.bindValue(":floor_id", floorId);

    if (!deleteQuery.exec()) {
        qCWarning(logDatabase) << "Delete failed:"
                   << deleteQuery.lastError();

        m_db.rollback();
        return false;
    }

    if (!items.empty()) {
        QSqlQuery insertQuery(m_db);

        insertQuery.prepare(R"(
            INSERT INTO canvas_items (
                floor_id,
                table_id,
                type,
                label,
                x,
                y,
                width,
                height,
                rotation,
                color,
                border_color,
                border_width,
                opacity,
                z_order,
                metadata
            ) VALUES (
                :floor_id,
                :table_id,
                :type,
                :label,
                :x,
                :y,
                :width,
                :height,
                :rotation,
                :color,
                :border_color,
                :border_width,
                :opacity,
                :z_order,
                :metadata
            )
        )");

        for (const CanvasItem& item : items) {

            insertQuery.bindValue(":floor_id", floorId);

            if (item.table_id.has_value())
                insertQuery.bindValue(
                    ":table_id",
                    item.table_id.value()
                );
            else
                insertQuery.bindValue(
                    ":table_id",
                    QVariant()
                );

            insertQuery.bindValue(":type", item.type);

            if (item.label.has_value())
                insertQuery.bindValue(
                    ":label",
                    item.label.value()
                );
            else
                insertQuery.bindValue(
                    ":label",
                    QVariant()
                );

            insertQuery.bindValue(":x", item.x);
            insertQuery.bindValue(":y", item.y);
            insertQuery.bindValue(":width", item.width);
            insertQuery.bindValue(":height", item.height);
            insertQuery.bindValue(":rotation", item.rotation);

            insertQuery.bindValue(":color", item.color);
            insertQuery.bindValue(":border_color", item.border_color);
            insertQuery.bindValue(":border_width", item.border_width);
            insertQuery.bindValue(":opacity", item.opacity);
            insertQuery.bindValue(":z_order", item.z_order);

            if (item.metadata.has_value())
                insertQuery.bindValue(
                    ":metadata",
                    item.metadata.value()
                );
            else
                insertQuery.bindValue(
                    ":metadata",
                    QVariant()
                );

            if (!insertQuery.exec()) {
                qCWarning(logDatabase) << "Insert failed:"
                           << insertQuery.lastError();

                m_db.rollback();
                return false;
            }
        }
    }

    if (!m_db.commit()) {
        qCWarning(logDatabase) << "Commit failed";

        m_db.rollback();
        return false;
    }

    return true;
}

bool CanvasItemRepository::remove(int id)
{
    QSqlQuery query(m_db);

    query.prepare(R"(
        DELETE FROM canvas_items
        WHERE id = :id
    )");

    query.bindValue(":id", id);

    return query.exec();
}
