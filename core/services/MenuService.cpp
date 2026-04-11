#include "MenuService.h"

#include "../models/CategoryModel.h"
#include "../models/MenuItemModel.h"

MenuService::MenuService(MenuRepository &menuRepo, 
                         CategoryRepository &categoryRepo,
                         QObject *parent)
    : QObject(parent), 
      m_menuRepo(menuRepo), 
      m_categoryRepo(categoryRepo)
{
    m_categoryModel = new CategoryModel(m_categoryRepo, this);
    m_menuItemModel = new MenuItemModel(m_menuRepo, this);
}

CategoryModel* MenuService::categoryModel() const
{
    return m_categoryModel;
}

MenuItemModel* MenuService::menuItemModel() const
{
    return m_menuItemModel;
}

int MenuService::currentCategoryId() const
{
    return m_currentCategoryId;
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

    m_categoryModel->reload();

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

    m_categoryModel->reload();

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

    m_categoryModel->reload();

    m_menuItemModel->reload(m_currentCategoryId);

    if (m_currentCategoryId == categoryId) {
        setCurrentCategoryId(-1);
    }

    return true;
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

    if (categoryId == m_currentCategoryId)
        m_menuItemModel->reload(categoryId);

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

    Menu menuItem = menuItemOpt.value();

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

    m_menuItemModel->reload(m_currentCategoryId);

    emit menuItemsChanged();

    return true;
}

bool MenuService::removeMenuItem(const int &menuItemId)
{
    auto menuItemOpt = m_menuRepo.getMenuItemById(menuItemId);
    if (!menuItemOpt.has_value()) {
        qWarning() << "Menu item with ID" << menuItemId << "not found";
        return false;
    }

    auto menuItem = menuItemOpt.value();
    int categoryId = menuItem.category_id;

    m_menuRepo.remove(menuItem);

    m_menuItemModel->reload(m_currentCategoryId);

    return true;
}

void MenuService::setCurrentCategoryId(int categoryId)
{
    if (m_currentCategoryId == categoryId)
        return;

    m_currentCategoryId = categoryId;
    emit currentCategoryIdChanged();

    m_menuItemModel->setCategory(categoryId);

    emit menuItemsChanged();
}
