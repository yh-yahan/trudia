#include "OrderItemModifierRepository.h"

#include <QSqlQuery>
#include <QSqlError>
#include <QVariant>
#include "../logging/LoggingCategories.h"

OrderItemModifierRepository::OrderItemModifierRepository(QSqlDatabase db): m_db(db) {}

std::vector<OrderItemModifier> OrderItemModifierRepository::getAll()
{
    std::vector<OrderItemModifier> modifiers;

    QSqlQuery query(m_db);
    query.prepare(R"(
        SELECT id, order_item_id, modifier_id, group_id, group_name, name, price_delta
        FROM order_item_modifiers
    )");

    if (!query.exec()) {
        qCWarning(logDatabase) << "getAll failed:" << query.lastError();
        return modifiers;
    }

    while (query.next()) {
        OrderItemModifier modifier;
        modifier.id = query.value("id").toInt();
        modifier.order_item_id = query.value("order_item_id").toInt();
        modifier.modifier_id = query.value("modifier_id").toInt();
        modifier.group_id = query.value("group_id").toInt();
        modifier.group_name = query.value("group_name").toString();
        modifier.name = query.value("name").toString();
        modifier.price_delta = query.value("price_delta").toInt();

        modifiers.push_back(modifier);
    }

    return modifiers;
}

std::optional<OrderItemModifier> OrderItemModifierRepository::getById(int id)
{
    QSqlQuery query(m_db);
    query.prepare(R"(
        SELECT id, order_item_id, modifier_id, group_id, group_name, name, price_delta
        FROM order_item_modifiers
        WHERE id = :id
    )");

    query.bindValue(":id", id);

    if (!query.exec()) {
        qCWarning(logDatabase) << "getById failed:" << query.lastError();
        return std::nullopt;
    }

    if (!query.next()) {
        return std::nullopt;
    }

    OrderItemModifier modifier;
    modifier.id = query.value("id").toInt();
    modifier.order_item_id = query.value("order_item_id").toInt();
    modifier.modifier_id = query.value("modifier_id").toInt();
    modifier.group_id = query.value("group_id").toInt();
    modifier.group_name = query.value("group_name").toString();
    modifier.name = query.value("name").toString();
    modifier.price_delta = query.value("price_delta").toInt();

    return modifier;
}

std::vector<OrderItemModifier> OrderItemModifierRepository::getByOrderItemId(int orderItemId)
{
    std::vector<OrderItemModifier> modifiers;

    QSqlQuery query(m_db);
    query.prepare(R"(
        SELECT id, order_item_id, modifier_id, group_id, group_name, name, price_delta
        FROM order_item_modifiers
        WHERE order_item_id = :order_item_id
    )");

    query.bindValue(":order_item_id", orderItemId);

    if (!query.exec()) {
        qCWarning(logDatabase) << "getByOrderItemId failed:" << query.lastError();
        return modifiers;
    }

    while (query.next()) {
        OrderItemModifier modifier;
        modifier.id = query.value("id").toInt();
        modifier.order_item_id = query.value("order_item_id").toInt();
        modifier.modifier_id = query.value("modifier_id").toInt();
        modifier.group_id = query.value("group_id").toInt();
        modifier.group_name = query.value("group_name").toString();
        modifier.name = query.value("name").toString();
        modifier.price_delta = query.value("price_delta").toInt();

        modifiers.push_back(modifier);
    }

    return modifiers;
}

bool OrderItemModifierRepository::removeByOrderItemId(int orderItemId)
{
    QSqlQuery query(m_db);

    query.prepare(R"(
        DELETE FROM order_item_modifiers
        WHERE order_item_id = :order_item_id
    )");

    query.bindValue(":order_item_id", orderItemId);

    if (!query.exec()) {
        qCWarning(logDatabase) << "Failed to delete order item modifiers by order item id:"
                                << query.lastError().text();
        return false;
    }

    return query.numRowsAffected() > 0;
}

void OrderItemModifierRepository::create(const OrderItemModifier &modifier)
{
    QSqlQuery query(m_db);
    query.prepare(R"(
        INSERT INTO order_item_modifiers (
            order_item_id,
            modifier_id,
            group_id,
            group_name,
            name,
            price_delta
        )
        VALUES (
            :order_item_id,
            :modifier_id,
            :group_id,
            :group_name,
            :name,
            :price_delta
        )
    )");

    query.bindValue(":order_item_id", modifier.order_item_id);

    if (modifier.modifier_id.has_value()) {
        query.bindValue(":modifier_id", modifier.modifier_id.value());
    } else {
        query.bindValue(":modifier_id", QVariant());
    }

    if (modifier.group_id.has_value()) {
        query.bindValue(":group_id", modifier.group_id.value());
    } else {
        query.bindValue(":group_id", QVariant());
    }

    query.bindValue(":group_name", modifier.group_name);
    query.bindValue(":name", modifier.name);
    query.bindValue(":price_delta", modifier.price_delta);

    if (!query.exec()) {
        qCWarning(logDatabase) << "create failed:" << query.lastError();
    }
}

void OrderItemModifierRepository::update(const OrderItemModifier &modifier)
{
    QSqlQuery query(m_db);
    query.prepare(R"(
        UPDATE order_item_modifiers
        SET order_item_id = :order_item_id,
        modifier_id = :modifier_id,
        group_id = :group_id,
        group_name = :group_name,
        name = :name,
        price_delta = :price_delta
        WHERE id = :id
    )");

    query.bindValue(":id", modifier.id);
    query.bindValue(":order_item_id", modifier.order_item_id);

    if (modifier.modifier_id.has_value()) {
        query.bindValue(":modifier_id", modifier.modifier_id.value());
    } else {
        query.bindValue(":modifier_id", QVariant());
    }

    if (modifier.group_id.has_value()) {
        query.bindValue(":group_id", modifier.group_id.value());
    } else {
        query.bindValue(":group_id", QVariant());
    }

    query.bindValue(":group_name", modifier.group_name);
    query.bindValue(":name", modifier.name);
    query.bindValue(":price_delta", modifier.price_delta);

    if (!query.exec()) {
        qCWarning(logDatabase) << "update failed:" << query.lastError();
    }
}

void OrderItemModifierRepository::remove(const OrderItemModifier &modifier)
{
    QSqlQuery query(m_db);
    query.prepare(R"(
        DELETE FROM order_item_modifiers
        WHERE id = :id
    )");

    query.bindValue(":id", modifier.id);

    if (!query.exec()) {
        qCWarning(logDatabase) << "remove failed:" << query.lastError();
    }
}
