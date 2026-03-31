#include "MenuService.h"

MenuService::MenuService(MenuRepository &menuRepo, CategoryRepository &categoryRepo)
    : m_menuRepo(menuRepo), m_categoryRepo(categoryRepo) {}

QVariantList MenuService::getAllCategories() const
{
    QVariantList categoriesList;

    const auto categories = m_categoryRepo.getAllCategories();

    for (const auto &category : categories) {
        QVariantMap categoryMap;
        categoryMap["id"] = category.id;
        categoryMap["category"] = category.category;

        categoriesList.append(categoryMap);
    }

    return categoriesList;
}

bool MenuService::addCategory(const QString &categoryName)
{
    if (categoryName.trimmed().isEmpty()) {
        qWarning() << "Cannot add empty category name";
        return false;
    }

    Category category;
    category.category = categoryName;

    m_categoryRepo.create(category);

    return true;
}

bool MenuService::renameCategory(const int &categoryId, const QString &newName)
{
    if (newName.trimmed().isEmpty()) {
        qWarning() << "Cannot rename category to empty name";
        return false;
    }

    auto categoryOpt = m_categoryRepo.getCategoryById(categoryId);
    if (!categoryOpt.has_value()) {
        qWarning() << "Category with ID" << categoryId << "not found";
        return false;
    }

    Category category = categoryOpt.value();
    category.category = newName;

    m_categoryRepo.update(category);
    return true;
}

bool MenuService::removeCategory(const int &categoryId)
{
    auto categoryOpt = m_categoryRepo.getCategoryById(categoryId);
    if (!categoryOpt.has_value()) {
        qWarning() << "Category with ID" << categoryId << "not found";
        return false;
    }

    m_categoryRepo.remove(categoryOpt.value());

    return true;
}

QVariantList MenuService::getAllMenuItems() const
{
    QVariantList menuList;

    const auto menuItems = m_menuRepo.getAllMenuItems();

    for (const auto &item : menuItems) {
        QVariantMap itemMap;
        itemMap["id"] = item.id;
        itemMap["item"] = item.item;
        itemMap["category_id"] = item.category_id;
        itemMap["price"] = item.price / 100.0;
        itemMap["is_available"] = item.is_available;
        itemMap["is_taxable"] = item.is_taxable;

        if (item.portion_size.has_value()) {
            itemMap["portion_size"] = item.portion_size.value();
        } else {
            itemMap["portion_size"] = QVariant();
        }

        menuList.append(itemMap);
    }

    return menuList;
}

QVariantList MenuService::getMenuItemsByCategory(int categoryId) const
{
    QVariantList list;
    const auto items = m_menuRepo.getMenuItemsByCategory(categoryId);

    for (const auto &item : items) {
        QVariantMap map;
        map["id"] = item.id;
        map["item"] = item.item;
        map["category_id"] = item.category_id;
        map["price"] = item.price / 100.0;
        map["is_available"] = item.is_available;
        map["is_taxable"] = item.is_taxable;

        map["portion_size"] = item.portion_size.has_value() ? item.portion_size.value() : QVariant();

        list.append(map);
    }

    return list;
}

bool MenuService::addMenuItem(const QString &itemName,
                              const int &categoryId,
                              const double &price,
                              const bool &isAvailable,
                              const bool &isTaxable,
                              const QString &portionSize)
{
    if (itemName.trimmed().isEmpty()) {
        qWarning() << "Item name cannot be empty";
        return false;
    }

    if (!m_categoryRepo.getCategoryById(categoryId).has_value()) {
        qWarning() << "Category with ID" << categoryId << "not found";
        return false;
    }

    Menu newItem;
    newItem.item = itemName;
    newItem.category_id = categoryId;
    newItem.price = qRound(price * 100.0);
    newItem.is_available = isAvailable;
    newItem.is_taxable = isTaxable;

    newItem.portion_size = portionSize.isEmpty() ? "" : portionSize;

    m_menuRepo.create(newItem);

    return true;
}

bool MenuService::editMenuItem(const int &menuItemId,
                               const QString &itemName,
                               const int &categoryId,
                               const double &price,
                               const bool &isAvailable,
                               const bool &isTaxable,
                               const QString &portionSize)
{
    auto menuItemOpt = m_menuRepo.getMenuItemById(menuItemId);
    if (!menuItemOpt.has_value()) {
        qWarning() << "Menu item with ID" << menuItemId << "not found";
        return false;
    }

    Menu &menuItem = menuItemOpt.value();

    if (!itemName.trimmed().isEmpty()) {
        menuItem.item = itemName;
    } else {
        qWarning() << "Item name cannot be empty";
        return false;
    }

    if (!m_categoryRepo.getCategoryById(categoryId).has_value()) {
        qWarning() << "Category with ID" << categoryId << "not found";
        return false;
    }

    menuItem.category_id = categoryId;
    menuItem.price = qRound(price * 100.0);
    menuItem.is_available = isAvailable;
    menuItem.is_taxable = isTaxable;
    menuItem.portion_size = portionSize.isEmpty() ? "" : portionSize;

    m_menuRepo.update(menuItem);

    return true;
}

bool MenuService::removeMenuItem(const int &menuItemId)
{
    auto menuItemOpt = m_menuRepo.getMenuItemById(menuItemId);
    if (!menuItemOpt.has_value()) {
        qWarning() << "Menu item with ID" << menuItemId << "not found";
        return false;
    }

    m_menuRepo.remove(menuItemOpt.value());

    return true;
}
