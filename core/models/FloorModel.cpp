#include "FloorModel.h"

#include "FloorModel.h"

FloorModel::FloorModel(QObject *parent) : QAbstractListModel(parent) {}

int FloorModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;

    return static_cast<int>(m_floors.size());
}

QVariant FloorModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() ||
        index.row() < 0 ||
        index.row() >= static_cast<int>(m_floors.size()))
        return QVariant();

    const Floor &floor = m_floors[index.row()];

    switch (role) {
    case IdRole:
        return floor.id;
    case NameRole:
        return floor.name;
    case FloorNumberRole:
        return floor.floor_number;
    case SortOrderRole:
        return floor.sort_order;
    case IsActiveRole:
        return floor.is_active;
    default:
        return QVariant();
    }
}

QHash<int, QByteArray> FloorModel::roleNames() const
{
    return {
        { IdRole, "id" },
        { NameRole, "name" },
        { FloorNumberRole, "floor_number" },
        { SortOrderRole, "sort_order" },
        { IsActiveRole, "is_active" }
    };
}

void FloorModel::setFloors(const std::vector<Floor> &floors)
{
    beginResetModel();
    m_floors = floors;
    endResetModel();
}

std::vector<Floor> FloorModel::floors() const
{
    return m_floors;
}

QVariantMap FloorModel::getFloor(int index) const
{
    QVariantMap map;

    if (index < 0 || index >= static_cast<int>(m_floors.size()))
        return map;

    const Floor &floor = m_floors[index];

    map["id"] = floor.id;
    map["name"] = floor.name;
    map["floor_number"] = floor.floor_number;
    map["sort_order"] = floor.sort_order;
    map["is_active"] = floor.is_active;

    return map;
}

void FloorModel::addFloor(const Floor &floor)
{
    int row = static_cast<int>(m_floors.size());

    beginInsertRows(QModelIndex(), row, row);
    m_floors.push_back(floor);
    endInsertRows();
}

void FloorModel::updateFloor(int index, const Floor &floor)
{
    if (index < 0 || index >= static_cast<int>(m_floors.size()))
        return;

    m_floors[index] = floor;

    QModelIndex modelIndex = createIndex(index, 0);
    emit dataChanged(modelIndex, modelIndex);
}

void FloorModel::removeFloor(int index)
{
    if (index < 0 || index >= static_cast<int>(m_floors.size()))
        return;

    beginRemoveRows(QModelIndex(), index, index);
    m_floors.erase(m_floors.begin() + index);
    endRemoveRows();
}
