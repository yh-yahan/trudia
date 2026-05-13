#include "CanvasItemModel.h"

CanvasItemModel::CanvasItemModel(QObject *parent) : QAbstractListModel(parent) {}

int CanvasItemModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;

    return static_cast<int>(m_items.size());
}

QVariant CanvasItemModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid())
        return QVariant();

    if (index.row() < 0 || index.row() >= static_cast<int>(m_items.size()))
        return QVariant();

    const CanvasItem &item = m_items[index.row()];

    switch (role) {
    case IdRole:
        return item.id;
    case TypeRole:
        return item.type;
    case LabelRole:
        return item.label.value_or(QString());
    case CapacityRole:
        return item.capacity.value_or(0);
    case XRole:
        return item.x;
    case YRole:
        return item.y;
    case WidthRole:
        return item.width;
    case HeightRole:
        return item.height;
    case RotationRole:
        return item.rotation;
    case ColorRole:
        return item.color;
    case BorderColorRole:
        return item.border_color;
    case BorderWidthRole:
        return item.border_width;
    case OpacityRole:
        return item.opacity;
    case ZOrderRole:
        return item.z_order;
    case MetadataRole:
        return item.metadata.has_value()
            ? QVariant(*item.metadata)
            : QVariant();
    default:
        return QVariant();
    }
}

QHash<int, QByteArray> CanvasItemModel::roleNames() const
{
    return {
        { IdRole, "id" },
        { TypeRole, "type" },
        { LabelRole, "label" },
        { CapacityRole, "capacity" },
        { XRole, "x" },
        { YRole, "y" },
        { WidthRole, "width" },
        { HeightRole, "height" },
        { RotationRole, "rotation" },
        { ColorRole, "color" },
        { BorderColorRole, "border_color" },
        { BorderWidthRole, "border_width" },
        { OpacityRole, "opacity" },
        { ZOrderRole, "z_order" },
        { MetadataRole, "metadata" }
    };
}

QVariantMap CanvasItemModel::get(int row) const
{
    QVariantMap map;
    if (row < 0 || row >= static_cast<int>(m_items.size()))
        return map;

    const CanvasItem &item = m_items[row];

    map["id"] = item.id;
    map["type"] = item.type;
    map["label"] = item.label.value_or(QString());
    map["capacity"] = item.capacity.value_or(0);
    map["x"] = item.x;
    map["y"] = item.y;

    return map;
}

void CanvasItemModel::setItems(const std::vector<CanvasItem> &items)
{
    beginResetModel();
    m_items = items;
    endResetModel();
}

std::vector<CanvasItem> CanvasItemModel::items() const
{
    return m_items;
}

void CanvasItemModel::addItem(const CanvasItem &item)
{
    int row = static_cast<int>(m_items.size());

    beginInsertRows(QModelIndex(), row, row);
    m_items.push_back(item);
    endInsertRows();
}

void CanvasItemModel::updateItem(int index, const CanvasItem &item)
{
    if (index < 0 || index >= static_cast<int>(m_items.size()))
        return;

    m_items[index] = item;

    QModelIndex modelIndex = createIndex(index, 0);
    emit dataChanged(modelIndex, modelIndex);
}

Qt::ItemFlags CanvasItemModel::flags(const QModelIndex &index) const
{
    if (!index.isValid())
        return Qt::NoItemFlags;

    return Qt::ItemIsEnabled | Qt::ItemIsSelectable | Qt::ItemIsEditable;
}

bool CanvasItemModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    if (!index.isValid() || index.row() < 0 || index.row() >= static_cast<int>(m_items.size()))
        return false;

    CanvasItem &item = m_items[index.row()];
    bool changed = false;

    switch (role) {
    case XRole:
        if (value.canConvert<double>()) {
            item.x = value.toDouble();
            changed = true;
        }
        break;

    case YRole:
        if (value.canConvert<double>()) {
            item.y = value.toDouble();
            changed = true;
        }
        break;

    case WidthRole:
        if (value.canConvert<double>()) {
            item.width = value.toDouble();
            changed = true;
        }
        break;

    case HeightRole:
        if (value.canConvert<double>()) {
            item.height = value.toDouble();
            changed = true;
        }
        break;

    case RotationRole:
        if (value.canConvert<double>()) {
            item.rotation = value.toDouble();
            changed = true;
        }
        break;

    case LabelRole:
        item.label = value.toString();
        changed = true;
        break;

    case ColorRole:
        item.color = value.toString();
        changed = true;
        break;

    case MetadataRole:
        if (value.canConvert<QString>()) {
            item.metadata = value.toString();
            changed = true;
        }
        break;

    default:
        return false;
    }

    if (changed) {
        emit dataChanged(index, index, {role});
        return true;
    }

    return false;
}

void CanvasItemModel::removeItem(int index)
{
    if (index < 0 || index >= static_cast<int>(m_items.size()))
        return;

    beginRemoveRows(QModelIndex(), index, index);
    m_items.erase(m_items.begin() + index);
    endRemoveRows();
}
