#include "MenuItemModel.h"

MenuItemModel::MenuItemModel(MenuRepository &repo, QObject *parent)
    : QAbstractListModel(parent), m_repo(repo)
{
}

int MenuItemModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;

    return m_data.size();
}

QVariant MenuItemModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_data.size())
        return {};

    const Menu &item = m_data[index.row()];

    switch (role) {
    case IdRole: return item.id;
    case ItemRole: return item.item;
    case PriceRole: return item.price / 100.0;
    case CategoryIdRole: return item.category_id;

    case PortionRole:
        return item.portion_size.has_value()
                   ? item.portion_size.value()
                   : "";

    case AvailableRole: return item.is_available;
    case TaxableRole: return item.is_taxable;
    }

    return {};
}

QHash<int, QByteArray> MenuItemModel::roleNames() const
{
    return {
        {IdRole, "id"},
        {ItemRole, "item"},
        {PriceRole, "price"},
        {CategoryIdRole, "categoryId"},
        {PortionRole, "portion"},
        {AvailableRole, "available"},
        {TaxableRole, "taxable"}
    };
}

void MenuItemModel::setCategory(int categoryId)
{
    if (m_currentCategoryId == categoryId)
        return;

    m_currentCategoryId = categoryId;
    reload(categoryId);
}

void MenuItemModel::reload(int categoryId)
{
    beginResetModel();

    auto items = m_repo.getMenuItemsByCategory(categoryId);

    m_data = QVector<Menu>(items.begin(), items.end());

    endResetModel();
}

void MenuItemModel::clear()
{
    beginResetModel();
    m_data.clear();
    endResetModel();
}
