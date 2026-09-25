#ifndef RECIPECOMPONENTEFFECT_H
#define RECIPECOMPONENTEFFECT_H

#include <QString>

#define RECIPE_COMPONENT_EFFECT(X) \
    X(Add, "add") \
    X(Replace, "replace") \
    X(Remove, "remove")

enum class RecipeComponentEffect {

#define X(name, key) name,

    RECIPE_COMPONENT_EFFECT(X)

#undef X

};

inline QString toString(RecipeComponentEffect reason)
{
    switch (reason) {

#define X(name, key) case RecipeComponentEffect::name: return QStringLiteral(key);

    RECIPE_COMPONENT_EFFECT(X)

#undef X

    }

    return {};
}

inline bool fromString(const QString &value, RecipeComponentEffect &reason)
{
#define X(name, key) \
    if (value == QStringLiteral(key)) { \
        reason = RecipeComponentEffect::name; \
        return true; \
    }

    RECIPE_COMPONENT_EFFECT(X)

#undef X

    return false;
}

#endif // RECIPECOMPONENTEFFECT_H
