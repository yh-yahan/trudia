#include "ModifiersService.h"
#include "../models/ModifiersModel.h"

#include <QSet>

namespace {
const QStringList kSelectionTypes{QStringLiteral("single"), QStringLiteral("multiple")};
}

ModifiersService::ModifiersService(ModifiersRepository &repository, QObject *parent)
    : QObject(parent), m_modifiersRepo(repository)
{
    m_modifierModel = new ModifiersModel(*this, this);
    m_menuModifierModel = new ModifiersModel(*this, this);

    m_modifierModel->loadGroups();
}

ModifiersService::~ModifiersService() = default;

ModifiersModel *ModifiersService::modifierModel() const
{
    return m_modifierModel;
}

ModifiersModel *ModifiersService::menuModifierModel() const
{
    return m_menuModifierModel;
}

int ModifiersService::currentMenuId() const
{
    return m_currentMenuId;
}

void ModifiersService::setCurrentMenuId(int menuId)
{
    if (m_currentMenuId == menuId)
        return;

    m_currentMenuId = menuId;
    emit currentMenuIdChanged();

    if (m_currentMenuId > 0)
        m_menuModifierModel->loadGroupsForMenu(m_currentMenuId);
    else
        m_menuModifierModel->loadGroupsForMenu(-1);
}

std::vector<ModifierGroup> ModifiersService::groups() const
{
    return m_modifiersRepo.getGroups();
}

std::optional<ModifierGroup> ModifiersService::group(int id) const
{
    return m_modifiersRepo.getGroup(id);
}

std::vector<Modifier> ModifiersService::modifiers(int groupId) const
{
    return m_modifiersRepo.getModifiers(groupId);
}

std::vector<ModifierGroup> ModifiersService::groupsForMenu(int menuId) const
{
    if (menuId <= 0)
        return {};
    return m_modifiersRepo.getGroupsForMenu(menuId);
}

QVariantMap ModifiersService::getGroup(int id) const
{
    const auto g = m_modifiersRepo.getGroup(id);
    if (!g)
        return {};
    return groupToMap(*g);
}

QVariantList ModifiersService::getModifiers(int groupId) const
{
    QVariantList list;
    for (const auto &m : m_modifiersRepo.getModifiers(groupId))
        list.push_back(modifierToMap(m));
    return list;
}

int ModifiersService::createGroup(const QString &name,
                                  const QString &selectionType,
                                  int minSelect,
                                  const QVariant &maxSelect,
                                  bool isRequired)
{
    const auto maxVal = toOptionalMax(maxSelect);
    if (!isValidGroup(name, selectionType, minSelect, maxVal, isRequired))
        return -1;

    ModifierGroup group;
    group.name = name.trimmed();
    group.selectionType = selectionType;
    group.minSelect = minSelect;
    group.maxSelect = maxVal;
    group.isRequired = isRequired;

    const int id = m_modifiersRepo.createGroup(group);
    if (id < 0) {
        emit errorOccurred(tr("Could not create modifier group."));
        return -1;
    }

    emit groupsChanged();
    m_modifierModel->loadGroups();
    return id;
}

bool ModifiersService::updateGroup(int id,
                                   const QString &name,
                                   const QString &selectionType,
                                   int minSelect,
                                   const QVariant &maxSelect,
                                   bool isRequired)
{
    if (id <= 0)
        return false;

    const auto maxVal = toOptionalMax(maxSelect);
    if (!isValidGroup(name, selectionType, minSelect, maxVal, isRequired))
        return false;

    ModifierGroup group;
    group.id = id;
    group.name = name.trimmed();
    group.selectionType = selectionType;
    group.minSelect = minSelect;
    group.maxSelect = maxVal;
    group.isRequired = isRequired;

    if (!m_modifiersRepo.updateGroup(group)) {
        emit errorOccurred(tr("Could not update modifier group."));
        return false;
    }

    emit groupsChanged();
    m_modifierModel->loadGroups();
    if (m_currentMenuId > 0)
        m_menuModifierModel->loadGroupsForMenu(m_currentMenuId);
    return true;
}

bool ModifiersService::deleteGroup(int id)
{
    if (id <= 0)
        return false;

    if (!m_modifiersRepo.deleteGroup(id)) {
        emit errorOccurred(tr("Could not delete modifier group."));
        return false;
    }

    emit groupsChanged();
    m_modifierModel->loadGroups();
    if (m_currentMenuId > 0)
        m_menuModifierModel->loadGroupsForMenu(m_currentMenuId);
    return true;
}

int ModifiersService::createModifier(int groupId,
                                     const QString &name,
                                     int priceDelta,
                                     bool isDefault,
                                     bool isAvailable,
                                     int sortOrder)
{
    if (!isValidModifier(groupId, name))
        return -1;

    Modifier modifier;
    modifier.groupId = groupId;
    modifier.name = name.trimmed();
    modifier.priceDelta = priceDelta * 100;
    modifier.isDefault = isDefault;
    modifier.isAvailable = isAvailable;
    modifier.sortOrder = (sortOrder >= 0) ? sortOrder : nextModifierSortOrder(groupId);

    const int id = m_modifiersRepo.createModifier(modifier);
    if (id < 0) {
        emit errorOccurred(tr("Could not create modifier."));
        return -1;
    }

    emit modifiersChanged(groupId);
    emit groupsChanged();
    m_modifierModel->loadGroups();
    if (m_currentMenuId > 0)
        m_menuModifierModel->loadGroupsForMenu(m_currentMenuId);
    return id;
}

bool ModifiersService::updateModifier(int id,
                                      const QString &name,
                                      int priceDelta,
                                      bool isDefault,
                                      bool isAvailable,
                                      int sortOrder)
{
    const auto existing = m_modifiersRepo.getModifier(id);
    if (!existing) {
        emit errorOccurred(tr("Modifier not found."));
        return false;
    }

    if (!isValidModifier(existing->groupId, name))
        return false;

    Modifier modifier = *existing;
    modifier.name = name.trimmed();
    modifier.priceDelta = priceDelta * 100;
    modifier.isDefault = isDefault;
    modifier.isAvailable = isAvailable;
    modifier.sortOrder = sortOrder;

    if (!m_modifiersRepo.updateModifier(modifier)) {
        emit errorOccurred(tr("Could not update modifier."));
        return false;
    }

    emit modifiersChanged(modifier.groupId);
    emit groupsChanged();
    m_modifierModel->loadGroups();
    if (m_currentMenuId > 0)
        m_menuModifierModel->loadGroupsForMenu(m_currentMenuId);
    return true;
}

bool ModifiersService::deleteModifier(int id)
{
    const auto existing = m_modifiersRepo.getModifier(id);
    if (!existing)
        return false;

    if (!m_modifiersRepo.deleteModifier(id)) {
        emit errorOccurred(tr("Could not delete modifier."));
        return false;
    }

    emit modifiersChanged(existing->groupId);
    emit groupsChanged();
    m_modifierModel->loadGroups();
    if (m_currentMenuId > 0)
        m_menuModifierModel->loadGroupsForMenu(m_currentMenuId);
    return true;
}

bool ModifiersService::attachGroupToMenu(int menuId, int groupId, int sortOrder)
{
    if (menuId <= 0 || groupId <= 0)
        return false;

    if (!m_modifiersRepo.getGroup(groupId)) {
        emit errorOccurred(tr("Modifier group not found."));
        return false;
    }

    const auto attached = m_modifiersRepo.getGroupsForMenu(menuId);
    for (const auto &g : attached) {
        if (g.id == groupId) {
            emit errorOccurred(tr("That group is already attached."));
            return false;
        }
    }

    const int order = (sortOrder >= 0) ? sortOrder : nextMenuGroupSortOrder(menuId);
    if (!m_modifiersRepo.attachGroupToMenu(menuId, groupId, order)) {
        emit errorOccurred(tr("Could not attach modifier group."));
        return false;
    }

    emit menuGroupsChanged(menuId);
    if (menuId == m_currentMenuId)
        m_menuModifierModel->loadGroupsForMenu(menuId);
    return true;
}

bool ModifiersService::detachGroupFromMenu(int menuId, int groupId)
{
    if (menuId <= 0 || groupId <= 0)
        return false;

    if (!m_modifiersRepo.detachGroupFromMenu(menuId, groupId)) {
        emit errorOccurred(tr("Could not detach modifier group."));
        return false;
    }

    emit menuGroupsChanged(menuId);
    if (menuId == m_currentMenuId)
        m_menuModifierModel->loadGroupsForMenu(menuId);
    return true;
}

void ModifiersService::reload()
{
    m_modifierModel->loadGroups();
}

void ModifiersService::reloadForMenu(int menuId)
{
    m_menuModifierModel->loadGroupsForMenu(menuId);
}

bool ModifiersService::isValidSelectionType(const QString &selectionType) const
{
    return kSelectionTypes.contains(selectionType);
}

bool ModifiersService::isValidGroup(const QString &name,
                                    const QString &selectionType,
                                    int minSelect,
                                    const std::optional<int> &maxSelect,
                                    bool isRequired)
{
    if (name.trimmed().isEmpty()) {
        emit errorOccurred(tr("Group name is required."));
        return false;
    }

    if (!isValidSelectionType(selectionType)) {
        emit errorOccurred(tr("Selection type must be \"single\" or \"multiple\"."));
        return false;
    }

    if (minSelect < 0) {
        emit errorOccurred(tr("Minimum selection cannot be negative."));
        return false;
    }

    if (isRequired && minSelect < 1) {
        emit errorOccurred(tr("Required groups need a minimum of 1."));
        return false;
    }

    if (selectionType == QLatin1String("single")) {
        const int maxVal = maxSelect.value_or(1);
        if (maxVal != 1) {
            emit errorOccurred(tr("Single-select groups must have a max of 1."));
            return false;
        }
        if (minSelect > 1) {
            emit errorOccurred(tr("Single-select groups cannot require more than 1."));
            return false;
        }
    }

    if (maxSelect.has_value() && maxSelect.value() < minSelect) {
        emit errorOccurred(tr("Max selection cannot be less than min selection."));
        return false;
    }

    return true;
}

bool ModifiersService::isValidModifier(int groupId, const QString &name)
{
    if (name.trimmed().isEmpty()) {
        emit errorOccurred(tr("Modifier name is required."));
        return false;
    }

    if (!m_modifiersRepo.getGroup(groupId)) {
        emit errorOccurred(tr("Modifier group not found."));
        return false;
    }

    return true;
}

std::optional<int> ModifiersService::toOptionalMax(const QVariant &maxSelect) const
{
    if (!maxSelect.isValid() || maxSelect.isNull())
        return std::nullopt;

    bool ok = false;
    const int value = maxSelect.toInt(&ok);
    if (!ok)
        return std::nullopt;
    return value;
}

QVariantMap ModifiersService::groupToMap(const ModifierGroup &group) const
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
    map.insert(QStringLiteral("modifiers"), getModifiers(group.id));
    return map;
}

QVariantMap ModifiersService::modifierToMap(const Modifier &modifier) const
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

int ModifiersService::nextModifierSortOrder(int groupId) const
{
    int maxOrder = -1;
    for (const auto &m : m_modifiersRepo.getModifiers(groupId))
        maxOrder = std::max(maxOrder, m.sortOrder);
    return maxOrder + 1;
}

int ModifiersService::nextMenuGroupSortOrder(int menuId) const
{
    return static_cast<int>(m_modifiersRepo.getGroupsForMenu(menuId).size());
}
