#ifndef RECIPECOMPONENTOWNERTYPE_H
#define RECIPECOMPONENTOWNERTYPE_H

#include <QString>

#define RECIPE_COMPONENT_OWNER_TYPE(X) \
    X(MenuItem, "menu_item") \
    X(InventoryItem, "inventory_item")

enum class RecipeComponentOwnerType {

#define X(name, key) name,

    RECIPE_COMPONENT_OWNER_TYPE(X)

#undef X

};

inline QString toString(RecipeComponentOwnerType reason)
{
    switch (reason) {

#define X(name, key) case RecipeComponentOwnerType::name: return QStringLiteral(key);

    RECIPE_COMPONENT_OWNER_TYPE(X)

#undef X

    }

    return {};
}

inline bool fromString(const QString &value, RecipeComponentOwnerType &reason)
{
#define X(name, key) \
    if (value == QStringLiteral(key)) { \
        reason = RecipeComponentOwnerType::name; \
        return true; \
    }

    RECIPE_COMPONENT_OWNER_TYPE(X)

#undef X

    return false;
}

#endif // RECIPECOMPONENTOWNERTYPE_H
