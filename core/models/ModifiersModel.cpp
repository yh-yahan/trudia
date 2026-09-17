#include "ModifiersModel.h"
#include "../services/ModifiersService.h"

ModifiersModel::ModifiersModel(ModifiersService &service, QObject *parent)
    : QAbstractListModel(parent)
    , m_service(service)
{
}

int ModifiersModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;
    return static_cast<int>(m_groups.size());
}

QVariant ModifiersModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() < 0 || index.row() >= rowCount())
        return {};

    const ModifierGroup &group = m_groups.at(static_cast<size_t>(index.row()));

    switch (role) {
    case IdRole:
        return group.id;
    case NameRole:
        return group.name;
    case SelectionTypeRole:
        return group.selectionType;
    case MinSelectRole:
        return group.minSelect;
    case MaxSelectRole:
        return group.maxSelect ? QVariant(*group.maxSelect) : QVariant();
    case IsRequiredRole:
        return group.isRequired;
    case CreatedAtRole:
        return group.createdAt;
    case ModifiersRole:
        return modifiersToList(group.id);
    default:
        return {};
    }
}

QHash<int, QByteArray> ModifiersModel::roleNames() const
{
    return {
            {IdRole, QByteArrayLiteral("id")},
            {NameRole, QByteArrayLiteral("name")},
            {SelectionTypeRole, QByteArrayLiteral("selectionType")},
            {MinSelectRole, QByteArrayLiteral("minSelect")},
            {MaxSelectRole, QByteArrayLiteral("maxSelect")},
            {IsRequiredRole, QByteArrayLiteral("isRequired")},
            {CreatedAtRole, QByteArrayLiteral("createdAt")},
            {ModifiersRole, QByteArrayLiteral("modifiers")},
            };
}

void ModifiersModel::loadGroups()
{
    beginResetModel();
    m_forMenu = false;
    m_menuId = -1;
    m_groups = m_service.groups();
    endResetModel();
}

void ModifiersModel::loadGroupsForMenu(int menuId)
{
    beginResetModel();
    m_forMenu = true;
    m_menuId = menuId;
    m_groups = m_service.groupsForMenu(menuId);
    endResetModel();
}

QVariantMap ModifiersModel::getGroup(int id) const
{
    const ModifierGroup *group = findGroup(id);
    if (group)
        return groupToMap(*group);
    return m_service.getGroup(id);
}

int ModifiersModel::createGroup(const QString &name,
                                const QString &selectionType,
                                int minSelect,
                                const QVariant &maxSelect,
                                bool isRequired)
{
    return m_service.createGroup(name, selectionType, minSelect, maxSelect, isRequired);
}

bool ModifiersModel::updateGroup(int id,
                                 const QString &name,
                                 const QString &selectionType,
                                 int minSelect,
                                 const QVariant &maxSelect,
                                 bool isRequired)
{
    return m_service.updateGroup(id, name, selectionType, minSelect, maxSelect, isRequired);
}

bool ModifiersModel::deleteGroup(int id)
{
    return m_service.deleteGroup(id);
}

int ModifiersModel::createModifier(int groupId,
                                   const QString &name,
                                   int priceDelta,
                                   bool isDefault,
                                   bool isAvailable,
                                   int sortOrder)
{
    return m_service.createModifier(groupId, name, priceDelta, isDefault, isAvailable, sortOrder);
}

bool ModifiersModel::updateModifier(int id,
                                    const QString &name,
                                    int priceDelta,
                                    bool isDefault,
                                    bool isAvailable,
                                    int sortOrder)
{
    return m_service.updateModifier(id, name, priceDelta, isDefault, isAvailable, sortOrder);
}

bool ModifiersModel::deleteModifier(int id)
{
    return m_service.deleteModifier(id);
}

QVariantMap ModifiersModel::groupToMap(const ModifierGroup &group) const
{
    QVariantMap map;
    map.insert(QStringLiteral("id"), group.id);
    map.insert(QStringLiteral("name"), group.name);
    map.insert(QStringLiteral("selectionType"), group.selectionType);
    map.insert(QStringLiteral("minSelect"), group.minSelect);
    map.insert(QStringLiteral("maxSelect"),
               group.maxSelect ? QVariant(*group.maxSelect) : QVariant());
    map.insert(QStringLiteral("isRequired"), group.isRequired);
    map.insert(QStringLiteral("createdAt"), group.createdAt);
    map.insert(QStringLiteral("modifiers"), modifiersToList(group.id));
    return map;
}

QVariantMap ModifiersModel::modifierToMap(const Modifier &modifier) const
{
    QVariantMap map;
    map.insert(QStringLiteral("id"), modifier.id);
    map.insert(QStringLiteral("groupId"), modifier.groupId);
    map.insert(QStringLiteral("name"), modifier.name);
    map.insert(QStringLiteral("priceDelta"), modifier.priceDelta / 100);
    map.insert(QStringLiteral("isDefault"), modifier.isDefault);
    map.insert(QStringLiteral("isAvailable"), modifier.isAvailable);
    map.insert(QStringLiteral("sortOrder"), modifier.sortOrder);
    map.insert(QStringLiteral("createdAt"), modifier.createdAt);
    return map;
}

QVariantList ModifiersModel::modifiersToList(int groupId) const
{
    QVariantList list;
    for (const auto &modifier : m_service.modifiers(groupId))
        list.push_back(modifierToMap(modifier));
    return list;
}

const ModifierGroup *ModifiersModel::findGroup(int id) const
{
    for (const auto &group : m_groups) {
        if (group.id == id)
            return &group;
    }
    return nullptr;
}
