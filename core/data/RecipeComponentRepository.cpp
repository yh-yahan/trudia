#include "RecipeComponentRepository.h"

#include <QSqlQuery>
#include <QSqlError>
#include <QVariant>

RecipeComponentRepository::RecipeComponentRepository(QSqlDatabase db)
    : m_db(db) {}

int RecipeComponentRepository::create(const RecipeComponent &row)
{
    if (row.owner_id < 0 || row.inventory_item_id < 0 || row.quantity <= 0) return -1;

    QSqlQuery query(m_db);

    query.prepare(R"(INSERT INTO recipe_components
        (owner_type, owner_id, inventory_item_id, quantity, unit,
        modifier_id, effect, sort_order)
        VALUES (:owner_type, :owner_id, :inventory_item_id, :quantity, :unit,
        :modifier_id, :effect, :sort_order))");

    query.bindValue(":owner_type", toString(row.owner_type));
    query.bindValue(":owner_id", row.owner_id);
    query.bindValue(":inventory_item_id", row.inventory_item_id);
    query.bindValue(":quantity", row.quantity);
    query.bindValue(":unit", toString(row.unit));

    if (row.modifier_id.has_value()) query.bindValue(":modifier_id", *row.modifier_id);
    else query.bindValue(":modifier_id", QVariant());

    query.bindValue(":effect", toString(row.effect));
    query.bindValue(":sort_order", row.sort_order);

    if (!query.exec())
        return -1;

    return query.lastInsertId().toInt();
}

bool RecipeComponentRepository::update(const RecipeComponent &row)
{
    if (row.id < 0 || row.owner_id < 0 || row.inventory_item_id < 0 || row.quantity <= 0) return false;

    QSqlQuery query(m_db);

    query.prepare(R"(UPDATE recipe_components SET
        owner_type = :owner_type,
        owner_id = :owner_id,
        inventory_item_id = :inventory_item_id,
        quantity = :quantity,
        unit = :unit,
        modifier_id = :modifier_id,
        effect = :effect,
        sort_order = :sort_order,
        updated_at = CURRENT_TIMESTAMP
        WHERE id = :id)");

    query.bindValue(":id", row.id);
    query.bindValue(":owner_type", toString(row.owner_type));
    query.bindValue(":owner_id", row.owner_id);
    query.bindValue(":inventory_item_id", row.inventory_item_id);
    query.bindValue(":quantity", row.quantity);
    query.bindValue(":unit", toString(row.unit));

    if (row.modifier_id.has_value()) query.bindValue(":modifier_id", *row.modifier_id);
    else query.bindValue(":modifier_id", QVariant());

    query.bindValue(":effect", toString(row.effect));
    query.bindValue(":sort_order", row.sort_order);

    return query.exec() && query.numRowsAffected() > 0;
}

bool RecipeComponentRepository::remove(int id)
{
    if (id < 0) return false;

    QSqlQuery query(m_db);

    query.prepare(R"(DELETE FROM recipe_components WHERE id = :id)");

    query.bindValue(":id", id);

    return query.exec() && query.numRowsAffected() > 0;
}

std::optional<RecipeComponent> RecipeComponentRepository::getById(int id) const
{
    if (id < 0) return std::nullopt;

    QSqlQuery query(m_db);

    query.prepare(R"(SELECT id, owner_type, owner_id, inventory_item_id,
        quantity, unit, modifier_id, effect, sort_order 
        FROM recipe_components 
        WHERE id = :id)");

    query.bindValue(":id", id);

    if (!query.exec() || !query.next())
        return std::nullopt;

    RecipeComponent row;

    row.id = query.value(0).toInt();

    fromString(query.value(1).toString(), row.owner_type);

    row.owner_id = query.value(2).toInt();
    row.inventory_item_id = query.value(3).toInt();
    row.quantity = query.value(4).toLongLong();
    fromString(query.value(5).toString(), row.unit);

    if (!query.value(6).isNull()) row.modifier_id = query.value(6).toInt();
    else row.modifier_id.reset();

    fromString(query.value(7).toString(), row.effect);

    row.sort_order = query.value(8).toInt();

    return row;
}

std::vector<RecipeComponent> RecipeComponentRepository::listByOwner(RecipeComponentOwnerType ownerType, int ownerId) const
{
    std::vector<RecipeComponent> rows;

    if (ownerId < 0) return rows;

    QSqlQuery query(m_db);

    query.prepare(R"(SELECT id, owner_type, owner_id, inventory_item_id,
        quantity, unit, modifier_id, effect, sort_order
        FROM recipe_components
        WHERE owner_type = :owner_type
        AND owner_id = :owner_id
        ORDER BY (modifier_id IS NOT NULL), sort_order, id)");

    query.bindValue(":owner_type", toString(ownerType));
    query.bindValue(":owner_id", ownerId);

    if (!query.exec()) return rows;

    while (query.next())
    {
        RecipeComponent row;

        row.id = query.value(0).toInt();

        fromString(query.value(1).toString(), row.owner_type);

        row.owner_id = query.value(2).toInt();
        row.inventory_item_id = query.value(3).toInt();
        row.quantity = query.value(4).toLongLong();
        fromString(query.value(5).toString(), row.unit);

        if (!query.value(6).isNull()) row.modifier_id = query.value(6).toInt();
        else row.modifier_id.reset();

        fromString(query.value(7).toString(), row.effect);

        row.sort_order = query.value(8).toInt();

        rows.push_back(row);
    }

    return rows;
}

bool RecipeComponentRepository::removeByModifier(int modifierId)
{
    QSqlQuery query(m_db);

    query.prepare(R"(
        DELETE FROM recipe_components
        WHERE modifier_id = :modifier_id
    )");

    query.bindValue(":modifier_id", modifierId);
    return query.exec();
}

bool RecipeComponentRepository::removeByOwnerAndModifier(const QString &ownerType, int ownerId, int modifierId)
{
    QSqlQuery query(m_db);

    query.prepare(R"(
        DELETE FROM recipe_components
        WHERE owner_type = :owner_type AND owner_id = :owner_id
        AND modifier_id = :modifier_id
    )");
        
    query.bindValue(":owner_type", ownerType);
    query.bindValue(":owner_id", ownerId);
    query.bindValue(":modifier_id", modifierId);
    return query.exec();
}
