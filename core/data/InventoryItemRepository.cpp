#include "InventoryItemRepository.h"

#include <QSqlQuery>
#include <QVariant>

InventoryItemRepository::InventoryItemRepository(QSqlDatabase db) : m_db(db) {}

std::vector<InventoryItem> InventoryItemRepository::getAll() const
{
    std::vector<InventoryItem> items;

    QSqlQuery query(m_db);
    query.prepare(R"(
        SELECT id, name, type, base_unit, quantity, low_quantity,
            is_active, is_sellable
        FROM inventory_items
        ORDER BY name
    )");

    if (!query.exec()) return items;

    while (query.next()) {
        InventoryItem item;
        item.id = query.value("id").toInt();
        item.name = query.value("name").toString();
        if (!fromString(query.value("type").toString(), item.type)) continue;
        if (!fromString(query.value("base_unit").toString(), item.base_unit)) continue;
        item.quantity = query.value("quantity").toInt();
        item.low_quantity = query.value("low_quantity").toInt();
        item.is_active = query.value("is_active").toBool();
        item.is_sellable = query.value("is_sellable").toBool();

        items.push_back(std::move(item));
    }

    return items;
}

std::optional<InventoryItem> InventoryItemRepository::getById(int id) const
{
    QSqlQuery query(m_db);
    query.prepare(R"(
        SELECT id, name, type, base_unit, quantity, low_quantity,
            is_active, is_sellable
        FROM inventory_items
        WHERE id = :id
    )");

    query.bindValue(":id", id);

    if (!query.exec() || !query.next()) return std::nullopt;

    InventoryItem item;
    item.id = query.value("id").toInt();
    item.name = query.value("name").toString();
    if (!fromString(query.value("type").toString(), item.type)) return std::nullopt;
    if (!fromString(query.value("base_unit").toString(), item.base_unit)) return std::nullopt;
    item.quantity = query.value("quantity").toInt();
    item.low_quantity = query.value("low_quantity").toInt();
    item.is_active = query.value("is_active").toBool();
    item.is_sellable = query.value("is_sellable").toBool();

    return item;
}

int InventoryItemRepository::create(const InventoryItem &item)
{
    QSqlQuery query(m_db);
    query.prepare(R"(
        INSERT INTO inventory_items (
            name, type, base_unit, quantity, low_quantity,
            is_active, is_sellable
        )
        VALUES (
            :name, :type, :base_unit, :quantity, :low_quantity,
            :is_active, :is_sellable
        )
    )");

    query.bindValue(":name", item.name);
    query.bindValue(":type", toString(item.type));
    query.bindValue(":base_unit", toString(item.base_unit));
    query.bindValue(":quantity", item.quantity);
    query.bindValue(":low_quantity", item.low_quantity);
    query.bindValue(":is_active", item.is_active);
    query.bindValue(":is_sellable", item.is_sellable);

    if (!query.exec()) return -1;

    return query.lastInsertId().toInt();
}

bool InventoryItemRepository::update(const InventoryItem &item)
{
    QSqlQuery query(m_db);
    query.prepare(R"(
        UPDATE inventory_items
        SET
            name = :name,
            type = :type,
            base_unit = :base_unit,
            quantity = :quantity,
            low_quantity = :low_quantity,
            is_active = :is_active,
            is_sellable = :is_sellable
        WHERE id = :id
    )");

    query.bindValue(":id", item.id);
    query.bindValue(":name", item.name);
    query.bindValue(":type", toString(item.type));
    query.bindValue(":base_unit", toString(item.base_unit));
    query.bindValue(":quantity", item.quantity);
    query.bindValue(":low_quantity", item.low_quantity);
    query.bindValue(":is_active", item.is_active);
    query.bindValue(":is_sellable", item.is_sellable);

    return query.exec();
}

bool InventoryItemRepository::remove(int id)
{
    QSqlQuery query(m_db);
    query.prepare(R"(
        DELETE FROM inventory_items
        WHERE id = :id
    )");

    query.bindValue(":id", id);

    return query.exec();
}
