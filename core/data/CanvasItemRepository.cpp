#include "CanvasItemRepository.h"

#include <QSqlQuery>
#include <QSqlError>
#include <QVariant>
#include <QDebug>

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
        qWarning() << "Failed to fetch canvas items:" << query.lastError();
        return items;
    }

    while (query.next()) {
        CanvasItem item;

        item.id = query.value("id").toInt();
        item.floor_id = query.value("floor_id").toInt();
        item.type = query.value("type").toString();

        if (!query.value("label").isNull())
            item.label = query.value("label").toString();

        if (!query.value("capacity").isNull())
            item.capacity = query.value("capacity").toInt();

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

bool CanvasItemRepository::saveAll(int floorId, const std::vector<CanvasItem>& items)
{
    if (!m_db.transaction()) {
        qWarning() << "Failed to begin transaction for saveAll";
        return false;
    }

    QSqlQuery deleteQuery(m_db);
    deleteQuery.prepare("DELETE FROM canvas_items WHERE floor_id = :floor_id");
    deleteQuery.bindValue(":floor_id", floorId);

    if (!deleteQuery.exec()) {
        qWarning() << "Delete failed:" << deleteQuery.lastError();
        m_db.rollback();
        return false;
    }

    if (!items.empty()) {
        QSqlQuery insertQuery(m_db);

        insertQuery.prepare(R"(
            INSERT INTO canvas_items (
                floor_id, type, label, capacity,
                x, y, width, height, rotation,
                color, border_color, border_width,
                opacity, z_order, metadata
            ) VALUES (
                :floor_id, :type, :label, :capacity,
                :x, :y, :width, :height, :rotation,
                :color, :border_color, :border_width,
                :opacity, :z_order, :metadata
            )
        )");

        for (const CanvasItem& item : items) {

            insertQuery.bindValue(":floor_id", floorId);
            insertQuery.bindValue(":type", item.type);

            if (item.label.has_value())
                insertQuery.bindValue(":label", item.label.value());
            else
                insertQuery.bindValue(":label", QVariant());

            if (item.capacity.has_value())
                insertQuery.bindValue(":capacity", item.capacity.value());
            else
                insertQuery.bindValue(":capacity", QVariant());

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

            if (item.capacity.has_value())
                insertQuery.bindValue(":metadata", item.metadata.value());
            else
                insertQuery.bindValue(":metadata", QVariant());

            if (!insertQuery.exec()) {
                qWarning() << "Insert failed:" << insertQuery.lastError();
                m_db.rollback();
                return false;
            }
        }
    }

    if (!m_db.commit()) {
        qWarning() << "Commit failed";
        m_db.rollback();
        return false;
    }

    return true;
}

bool CanvasItemRepository::remove(int id)
{
    QSqlQuery query(m_db);
    query.prepare("DELETE FROM canvas_items WHERE id = :id");
    query.bindValue(":id", id);

    return query.exec();
}
