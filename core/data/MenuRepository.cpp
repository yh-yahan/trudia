#include "MenuRepository.h"

#include <QSqlQuery>
#include <QSqlError>
#include <QVariant>
#include "../logging/LoggingCategories.h"

MenuRepository::MenuRepository(QSqlDatabase db): m_db(db) {}

std::vector<Menu> MenuRepository::getAllMenuItems()
{
    std::vector<Menu> menuItems;

    QSqlQuery query(m_db);
    query.prepare(R"(SELECT id, item, category_id, price, 
        portion_size, is_available, is_taxable 
        FROM menu WHERE deleted_at IS NULL)");

    if (!query.exec()) {
        qCWarning(logDatabase) << "getAllCategories failed:" << query.lastError();
        return menuItems;
    }

    while (query.next()) {
        Menu menu;
        menu.id = query.value("id").toInt();
        menu.item = query.value("item").toString();
        menu.category_id = query.value("category_id").toInt();
        menu.price = query.value("price").toInt();
        menu.portion_size = query.value("portion_size").toString();
        menu.is_available = query.value("is_available").toBool();
        menu.is_taxable = query.value("is_taxable").toBool();
        
        menuItems.push_back(menu);
    }

    return menuItems;
}

std::optional<Menu> MenuRepository::getMenuItemById(int menuId)
{
    QSqlQuery query(m_db);
    query.prepare(R"(SELECT id, item, category_id, price, 
        portion_size, is_available, is_taxable
        FROM menu
        WHERE id = :id AND deleted_at IS NULL)");
    query.bindValue(":id", menuId);

    if (!query.exec()) {
        qCWarning(logDatabase) << "getMenuItemById failed:" << query.lastError();
        return std::nullopt;
    }

    if (!query.next()) {
        return std::nullopt;
    }

    Menu menu;
    menu.id = query.value("id").toInt();
    menu.item = query.value("item").toString();
    menu.category_id = query.value("category_id").toInt();
    menu.price = query.value("price").toInt();
    menu.portion_size = query.value("portion_size").toString();
    menu.is_available = query.value("is_available").toBool();
    menu.is_taxable = query.value("is_taxable").toBool();

    return menu;
}

std::vector<Menu> MenuRepository::getMenuItemsByCategory(int categoryId)
{
    std::vector<Menu> menuItems;

    QSqlQuery query(m_db);
    query.prepare(R"(
        SELECT id, item, category_id, price, portion_size, is_available, is_taxable 
        FROM menu
        WHERE category_id = :category_id AND deleted_at IS NULL
    )");
    
    query.bindValue(":category_id", categoryId);

    if (!query.exec()) {
        qCWarning(logDatabase) << "getMenuItemsByCategory failed:" << query.lastError();
        return menuItems;
    }

    while (query.next()) {
        Menu menu;
        menu.id = query.value("id").toInt();
        menu.item = query.value("item").toString();
        menu.category_id = query.value("category_id").toInt();
        menu.price = query.value("price").toInt();
        menu.portion_size = query.value("portion_size").toString();
        menu.is_available = query.value("is_available").toBool();
        menu.is_taxable = query.value("is_taxable").toBool();

        menuItems.push_back(menu);
    }

    return menuItems;
}

void MenuRepository::create(const Menu &menu)
{
    QSqlQuery query(m_db);
    query.prepare(R"(
        INSERT INTO menu (item, category_id, price, portion_size, is_available, is_taxable)
        VALUES (:item, :category_id, :price, :portion_size, :is_available, :is_taxable)
    )");

    query.bindValue(":item", menu.item);
    query.bindValue(":category_id", menu.category_id);
    query.bindValue(":price", menu.price);
    if (menu.portion_size.has_value()) {
        query.bindValue(":portion_size", menu.portion_size.value());
    } else {
        query.bindValue(":portion_size", "");
    }
    query.bindValue(":is_available", menu.is_available);
    query.bindValue(":is_taxable", menu.is_taxable);

    if (!query.exec()) {
        qCWarning(logDatabase) << "create failed:" << query.lastError();
    }
}

void MenuRepository::update(const Menu &menu)
{
    QSqlQuery query(m_db);
    query.prepare(R"(
        UPDATE menu
        SET item = :item,
        category_id = :category_id,
        price = :price,
        portion_size = :portion_size,
        is_available = :is_available,
        is_taxable = :is_taxable,
        updated_at = CURRENT_TIMESTAMP
        WHERE id = :menu_item_id
    )");

    query.bindValue(":menu_item_id", menu.id);
    query.bindValue(":item", menu.item);
    query.bindValue(":category_id", menu.category_id);
    query.bindValue(":price", menu.price);
    if (menu.portion_size.has_value()) {
        query.bindValue(":portion_size", menu.portion_size.value());
    } else {
        query.bindValue(":portion_size", "");
    }
    query.bindValue(":is_available", menu.is_available);
    query.bindValue(":is_taxable", menu.is_taxable);

    if (!query.exec()) {
        qCWarning(logDatabase) << "update failed:" << query.lastError();
    }
}

bool MenuRepository::remove(const Menu &menu)
{
    QSqlQuery query(m_db);
    query.prepare(R"(
        UPDATE menu 
        SET deleted_at = CURRENT_TIMESTAMP
        WHERE id = :menu_item_id
    )");

    query.bindValue(":menu_item_id", menu.id);

    if (!query.exec()) {
        qCWarning(logDatabase) << "remove failed:" << query.lastError();

        return false;
    }

    return true;
}
