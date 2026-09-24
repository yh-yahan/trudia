#ifndef INVENTORYTYPE_H
#define INVENTORYTYPE_H

#include <QString>

#define INVENTORY_TYPES(X) \
    X(Ingredient, "ingredient") \
    X(FinishedProduct, "finishedProduct") \
    X(Packaging, "packaging") \
    X(Prep, "prep")

enum class InventoryType {

#define X(name, key) name,

    INVENTORY_TYPES(X)

#undef X

};

inline QString toString(InventoryType type)
{
    switch (type) {

#define X(name, key) case InventoryType::name: return QStringLiteral(key);

    INVENTORY_TYPES(X)

#undef X

    }

    return {};
}

inline bool fromString(const QString &value, InventoryType &type)
{
#define X(name, key) \
    if (value == QStringLiteral(key)) { \
        type = InventoryType::name; \
        return true; \
    }

    INVENTORY_TYPES(X)

#undef X

    return false;
}

#endif // INVENTORYTYPE_H
