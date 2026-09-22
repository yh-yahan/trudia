#define INVENTORY_BASE_UNITS(X) \
    X(Gram, "g") \
    X(Kilogram, "kg") \
    X(Ounce, "oz") \
    X(Pound, "lb") \
    X(Milliliter, "ml") \
    X(Liter, "L") \
    X(FluidOunce, "fl_oz") \
    X(Gallon, "gal") \
    X(Quart, "qt") \
    X(Pint, "pt") \
    X(Cup, "cup") \
    X(Unit, "unit") \
    X(Dozen, "dozen") \
    X(Pack, "pack") \
    X(Box, "box") \
    X(Bag, "bag") \
    X(Bottle, "bottle") \
    X(Can, "can") \
    X(Carton, "carton") \
    X(Case, "case")

enum class InventoryBaseUnit {
#define X(name, key) name,
    INVENTORY_BASE_UNITS(X)
#undef X
};

inline QString toString(InventoryBaseUnit unit)
{
    switch (unit) {
#define X(name, key) case InventoryBaseUnit::name: return QStringLiteral(key);
    INVENTORY_BASE_UNITS(X)
#undef X
    }
    return {};
}

inline bool fromString(const QString &value, InventoryBaseUnit &unit)
{
#define X(name, key) \
    if (value == QStringLiteral(key)) { \
        unit = InventoryBaseUnit::name; \
        return true; \
    }

    INVENTORY_BASE_UNITS(X)

#undef X

    return false;
}
