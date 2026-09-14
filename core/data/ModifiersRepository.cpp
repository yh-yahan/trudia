#include "ModifiersRepository.h"

#include <QSqlQuery>
#include <QSqlError>
#include <QVariant>

#include "../logging/LoggingCategories.h"

ModifiersRepository::ModifiersRepository(QSqlDatabase db) : m_db(db) {}

std::vector<ModifierGroup> ModifiersRepository::getGroups()
{
    std::vector<ModifierGroup> groups;

    QSqlQuery query(m_db);

    query.prepare(R"(
        SELECT
            id,
            name,
            selection_type,
            min_select,
            max_select,
            is_required,
            created_at
        FROM modifier_groups
        ORDER BY id
    )");

    if (!query.exec()) {
        qCWarning(logDatabase) << "Failed to get modifier groups:"
                                << query.lastError().text();
        return groups;
    }

    while (query.next()) {
        ModifierGroup group;

        group.id = query.value("id").toInt();
        group.name = query.value("name").toString();
        group.selectionType = query.value("selection_type").toString();
        group.minSelect = query.value("min_select").toInt();

        if (query.value("max_select").isNull()) {
            group.maxSelect = std::nullopt;
        } else {
            group.maxSelect = query.value("max_select").toInt();
        }

        group.isRequired = query.value("is_required").toBool();
        group.createdAt = query.value("created_at").toString();

        groups.push_back(group);
    }

    return groups;
}

std::optional<ModifierGroup> ModifiersRepository::getGroup(int id)
{
    QSqlQuery query(m_db);

    query.prepare(R"(
        SELECT
            id,
            name,
            selection_type,
            min_select,
            max_select,
            is_required,
            created_at
        FROM modifier_groups
        WHERE id = :id
    )");

    query.bindValue(":id", id);

    if (!query.exec()) {
        qCWarning(logDatabase) << "Failed to get modifier group:"
                                << query.lastError().text();
        return std::nullopt;
    }

    if (!query.next()) {
        return std::nullopt;
    }

    ModifierGroup group;

    group.id = query.value("id").toInt();
    group.name = query.value("name").toString();
    group.selectionType = query.value("selection_type").toString();
    group.minSelect = query.value("min_select").toInt();

    if (query.value("max_select").isNull()) {
        group.maxSelect = std::nullopt;
    } else {
        group.maxSelect = query.value("max_select").toInt();
    }

    group.isRequired = query.value("is_required").toBool();
    group.createdAt = query.value("created_at").toString();

    return group;
}

int ModifiersRepository::createGroup(const ModifierGroup &group)
{
    QSqlQuery query(m_db);

    query.prepare(R"(
        INSERT INTO modifier_groups (
            name,
            selection_type,
            min_select,
            max_select,
            is_required
        )
        VALUES (
            :name,
            :selection_type,
            :min_select,
            :max_select,
            :is_required
        )
    )");

    query.bindValue(":name", group.name);
    query.bindValue(":selection_type", group.selectionType);
    query.bindValue(":min_select", group.minSelect);

    if (group.maxSelect.has_value()) {
        query.bindValue(":max_select", group.maxSelect.value());
    } else {
        query.bindValue(":max_select", QVariant());
    }

    query.bindValue(":is_required", group.isRequired);

    if (!query.exec()) {
        qCWarning(logDatabase) << "Failed to create modifier group:"
                                << query.lastError().text();
        return -1;
    }

    return query.lastInsertId().toInt();
}

bool ModifiersRepository::updateGroup(const ModifierGroup &group)
{
    QSqlQuery query(m_db);

    query.prepare(R"(
        UPDATE modifier_groups
        SET
            name = :name,
            selection_type = :selection_type,
            min_select = :min_select,
            max_select = :max_select,
            is_required = :is_required
        WHERE id = :id
    )");

    query.bindValue(":id", group.id);
    query.bindValue(":name", group.name);
    query.bindValue(":selection_type", group.selectionType);
    query.bindValue(":min_select", group.minSelect);

    if (group.maxSelect.has_value()) {
        query.bindValue(":max_select", group.maxSelect.value());
    } else {
        query.bindValue(":max_select", QVariant());
    }

    query.bindValue(":is_required", group.isRequired);

    if (!query.exec()) {
        qCWarning(logDatabase) << "Failed to update modifier group:"
                                << query.lastError().text();
        return false;
    }

    return query.numRowsAffected() > 0;
}

bool ModifiersRepository::deleteGroup(int id)
{
    QSqlQuery query(m_db);

    query.prepare(R"(
        DELETE FROM modifier_groups
        WHERE id = :id
    )");

    query.bindValue(":id", id);

    if (!query.exec()) {
        qCWarning(logDatabase) << "Failed to delete modifier group:"
                                << query.lastError().text();
        return false;
    }

    return query.numRowsAffected() > 0;
}

std::vector<Modifier> ModifiersRepository::getModifiers(int groupId)
{
    std::vector<Modifier> modifiers;

    QSqlQuery query(m_db);

    query.prepare(R"(
        SELECT
            id,
            group_id,
            name,
            price_delta,
            is_default,
            is_available,
            sort_order,
            created_at
        FROM modifiers
        WHERE group_id = :group_id
        ORDER BY sort_order, id
    )");

    query.bindValue(":group_id", groupId);

    if (!query.exec()) {
        qCWarning(logDatabase) << "Failed to get modifiers:"
                                << query.lastError().text();
        return modifiers;
    }

    while (query.next()) {
        Modifier modifier;

        modifier.id = query.value("id").toInt();
        modifier.groupId = query.value("group_id").toInt();
        modifier.name = query.value("name").toString();
        modifier.priceDelta = query.value("price_delta").toInt();
        modifier.isDefault = query.value("is_default").toBool();
        modifier.isAvailable = query.value("is_available").toBool();
        modifier.sortOrder = query.value("sort_order").toInt();
        modifier.createdAt = query.value("created_at").toString();

        modifiers.push_back(modifier);
    }

    return modifiers;
}

std::optional<Modifier> ModifiersRepository::getModifier(int id)
{
    QSqlQuery query(m_db);

    query.prepare(R"(
        SELECT
            id,
            group_id,
            name,
            price_delta,
            is_default,
            is_available,
            sort_order,
            created_at
        FROM modifiers
        WHERE id = :id
    )");

    query.bindValue(":id", id);

    if (!query.exec()) {
        qCWarning(logDatabase) << "Failed to get modifier:"
                                << query.lastError().text();
        return std::nullopt;
    }

    if (!query.next()) {
        return std::nullopt;
    }

    Modifier modifier;

    modifier.id = query.value("id").toInt();
    modifier.groupId = query.value("group_id").toInt();
    modifier.name = query.value("name").toString();
    modifier.priceDelta = query.value("price_delta").toInt();
    modifier.isDefault = query.value("is_default").toBool();
    modifier.isAvailable = query.value("is_available").toBool();
    modifier.sortOrder = query.value("sort_order").toInt();
    modifier.createdAt = query.value("created_at").toString();

    return modifier;
}

int ModifiersRepository::createModifier(const Modifier &modifier)
{
    QSqlQuery query(m_db);

    query.prepare(R"(
        INSERT INTO modifiers (
            group_id,
            name,
            price_delta,
            is_default,
            is_available,
            sort_order
        )
        VALUES (
            :group_id,
            :name,
            :price_delta,
            :is_default,
            :is_available,
            :sort_order
        )
    )");

    query.bindValue(":group_id", modifier.groupId);
    query.bindValue(":name", modifier.name);
    query.bindValue(":price_delta", modifier.priceDelta);
    query.bindValue(":is_default", modifier.isDefault);
    query.bindValue(":is_available", modifier.isAvailable);
    query.bindValue(":sort_order", modifier.sortOrder);

    if (!query.exec()) {
        qCWarning(logDatabase) << "Failed to create modifier:"
                                << query.lastError().text();
        return -1;
    }

    return query.lastInsertId().toInt();
}

bool ModifiersRepository::updateModifier(const Modifier &modifier)
{
    QSqlQuery query(m_db);

    query.prepare(R"(
        UPDATE modifiers
        SET
            group_id = :group_id,
            name = :name,
            price_delta = :price_delta,
            is_default = :is_default,
            is_available = :is_available,
            sort_order = :sort_order
        WHERE id = :id
    )");

    query.bindValue(":id", modifier.id);
    query.bindValue(":group_id", modifier.groupId);
    query.bindValue(":name", modifier.name);
    query.bindValue(":price_delta", modifier.priceDelta);
    query.bindValue(":is_default", modifier.isDefault);
    query.bindValue(":is_available", modifier.isAvailable);
    query.bindValue(":sort_order", modifier.sortOrder);

    if (!query.exec()) {
        qCWarning(logDatabase) << "Failed to update modifier:"
                                << query.lastError().text();
        return false;
    }

    return query.numRowsAffected() > 0;
}

bool ModifiersRepository::deleteModifier(int id)
{
    QSqlQuery query(m_db);

    query.prepare(R"(
        DELETE FROM modifiers
        WHERE id = :id
    )");

    query.bindValue(":id", id);

    if (!query.exec()) {
        qCWarning(logDatabase) << "Failed to delete modifier:"
                                << query.lastError().text();
        return false;
    }

    return query.numRowsAffected() > 0;
}

std::vector<ModifierGroup> ModifiersRepository::getGroupsForMenu(int menuId)
{
    std::vector<ModifierGroup> groups;

    QSqlQuery query(m_db);

    query.prepare(R"(
        SELECT
            mg.id,
            mg.name,
            mg.selection_type,
            mg.min_select,
            mg.max_select,
            mg.is_required,
            mg.created_at
        FROM modifier_groups mg
        INNER JOIN menu_modifier_groups mmg
            ON mmg.group_id = mg.id
        WHERE mmg.menu_id = :menu_id
        ORDER BY mmg.sort_order, mg.id
    )");

    query.bindValue(":menu_id", menuId);

    if (!query.exec()) {
        qCWarning(logDatabase) << "Failed to get modifier groups for menu:"
                                << query.lastError().text();
        return groups;
    }

    while (query.next()) {
        ModifierGroup group;

        group.id = query.value("id").toInt();
        group.name = query.value("name").toString();
        group.selectionType = query.value("selection_type").toString();
        group.minSelect = query.value("min_select").toInt();

        if (query.value("max_select").isNull()) {
            group.maxSelect = std::nullopt;
        } else {
            group.maxSelect = query.value("max_select").toInt();
        }

        group.isRequired = query.value("is_required").toBool();
        group.createdAt = query.value("created_at").toString();

        groups.push_back(group);
    }

    return groups;
}

bool ModifiersRepository::attachGroupToMenu(int menuId, int groupId, int sortOrder)
{
    QSqlQuery query(m_db);

    query.prepare(R"(
        INSERT INTO menu_modifier_groups (
            menu_id,
            group_id,
            sort_order
        )
        VALUES (
            :menu_id,
            :group_id,
            :sort_order
        )
    )");

    query.bindValue(":menu_id", menuId);
    query.bindValue(":group_id", groupId);
    query.bindValue(":sort_order", sortOrder);

    if (!query.exec()) {
        qCWarning(logDatabase) << "Failed to attach modifier group to menu:"
                                << query.lastError().text();
        return false;
    }

    return true;
}

bool ModifiersRepository::detachGroupFromMenu(int menuId, int groupId)
{
    QSqlQuery query(m_db);

    query.prepare(R"(
        DELETE FROM menu_modifier_groups
        WHERE menu_id = :menu_id
          AND group_id = :group_id
    )");

    query.bindValue(":menu_id", menuId);
    query.bindValue(":group_id", groupId);

    if (!query.exec()) {
        qCWarning(logDatabase) << "Failed to detach modifier group from menu:"
                                << query.lastError().text();
        return false;
    }

    return query.numRowsAffected() > 0;
}
