#include "TableModel.h"

TableModel::TableModel(TableRepository &repo, QObject *parent)
    : QAbstractListModel(parent),
    m_repo(repo)
{
}

int TableModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;

    return m_data.size();
}

QVariant TableModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() < 0 || index.row() >= m_data.size())
        return QVariant();

    const Table &table = m_data.at(index.row());

    switch (role) {
    case IdRole:
        return table.id;
    case NameRole:
        return table.table_number;
    case CapacityRole:
        return table.capacity;
    case ActiveRole:
        return table.is_active;
    default:
        return QVariant();
    }
}

QHash<int, QByteArray> TableModel::roleNames() const
{
    return {
        { IdRole, "id" },
        { NameRole, "name" },
        { CapacityRole, "capacity" },
        { ActiveRole, "is_active" }
    };
}

void TableModel::reload()
{
    beginResetModel();

    m_data.clear();

    const auto tables = m_repo.getAllTables();
    m_data.reserve(static_cast<int>(tables.size()));

    for (const auto &table : tables) {
        m_data.append(table);
    }

    endResetModel();
}

void TableModel::clear()
{
    beginResetModel();
    m_data.clear();
    endResetModel();
}
