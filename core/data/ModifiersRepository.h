#ifndef MODIFIERSREPOSITORY_H
#define MODIFIERSREPOSITORY_H

#include <vector>
#include <QSqlDatabase>
#include "../domain/Modifier.h"

class ModifiersRepository
{
public:
    explicit ModifiersRepository(QSqlDatabase db);

    std::vector<ModifierGroup> getGroups();
    std::optional<ModifierGroup> getGroup(int id);
    int createGroup(const ModifierGroup &group);
    bool updateGroup(const ModifierGroup &group);
    bool deleteGroup(int id);

    std::vector<Modifier> getModifiers(int groupId);
    std::optional<Modifier> getModifier(int id);
    int createModifier(const Modifier &modifier);
    bool updateModifier(const Modifier &modifier);
    bool deleteModifier(int id);

    std::vector<ModifierGroup> getGroupsForMenu(int menuId);
    bool attachGroupToMenu(int menuId, int groupId, int sortOrder = 0);
    bool detachGroupFromMenu(int menuId, int groupId);

private:
    QSqlDatabase m_db;
};

#endif // MODIFIERSREPOSITORY_H
