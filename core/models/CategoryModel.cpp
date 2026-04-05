#include "CategoryModel.h"

CategoryModel::CategoryModel(CategoryRepository &repo, QObject *parent)
    : QAbstractListModel(parent), m_repo(repo)
{
    reload();
}

int CategoryModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;

    return m_data.size();
}

QVariant CategoryModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_data.size())
        return {};

    const Category &cat = m_data[index.row()];

    switch (role) {
    case IdRole:
        return cat.id;
    case NameRole:
        return cat.category;
    }

    return {};
}

QHash<int, QByteArray> CategoryModel::roleNames() const
{
    return {
        {IdRole, "id"},
        {NameRole, "name"}
    };
}

void CategoryModel::reload()
{
    beginResetModel();

    auto categories = m_repo.getAllCategories();

    m_data = QVector<Category>(categories.begin(), categories.end());

    endResetModel();
}

void CategoryModel::clear()
{
    beginResetModel();
    m_data.clear();
    endResetModel();
}
