#ifndef MODIFIER_H
#define MODIFIER_H

#include <QString>

#include <optional>

struct ModifierGroup
{
    int id = -1;
    QString name;
    QString selectionType;
    int minSelect = 0;
    std::optional<int> maxSelect;
    bool isRequired = false;
    QString createdAt;
};

struct Modifier
{
    int id = -1;
    int groupId = -1;
    QString name;
    int priceDelta = 0;
    bool isDefault = false;
    bool isAvailable = true;
    int sortOrder = 0;
    QString createdAt;
};

struct MenuModifierGroup
{
    int menuId = -1;
    int groupId = -1;
    int sortOrder = 0;
};

#endif // MODIFIER_H
