enum class UnitCategory { Weight, Volume, Count };

#define INVENTORY_BASE_UNITS(X) \
    X(Gram, "g", UnitCategory::Weight, 1.0) \
    X(Kilogram, "kg", UnitCategory::Weight, 1000.0) \
    X(Ounce, "oz", UnitCategory::Weight, 28.3495) \
    X(Pound, "lb", UnitCategory::Weight, 453.592) \
    X(Milliliter, "ml", UnitCategory::Volume, 1.0) \
    X(Liter, "L", UnitCategory::Volume, 1000.0) \
    X(FluidOunce, "fl_oz",  UnitCategory::Volume,  29.5735) \
    X(Gallon, "gal", UnitCategory::Volume, 3785.41) \
    X(Quart, "qt", UnitCategory::Volume, 946.353) \
    X(Pint, "pt", UnitCategory::Volume, 473.176) \
    X(Cup, "cup", UnitCategory::Volume, 236.588) \
    X(Unit, "unit", UnitCategory::Count, 1.0) \
    X(Dozen, "dozen", UnitCategory::Count, 12.0) \
    X(Pack, "pack", UnitCategory::Count, 1.0) \
    X(Box, "box", UnitCategory::Count, 1.0) \
    X(Bag, "bag", UnitCategory::Count, 1.0) \
    X(Bottle, "bottle", UnitCategory::Count, 1.0) \
    X(Can, "can", UnitCategory::Count, 1.0) \
    X(Carton, "carton", UnitCategory::Count, 1.0) \
    X(Case, "case", UnitCategory::Count, 1.0)

enum class InventoryBaseUnit {
#define X(name, key, category, factor) name,
    INVENTORY_BASE_UNITS(X)
#undef X
};

struct UnitInfo {
    QString key;
    UnitCategory category;
    double toCanonical;
};

inline const UnitInfo &info(InventoryBaseUnit unit)
{
    static const UnitInfo infos[] = {
#define X(name, key, category, factor) { QStringLiteral(key), category, factor },
        INVENTORY_BASE_UNITS(X)
#undef X
    };
    return infos[static_cast<int>(unit)];
}

inline QString toString(InventoryBaseUnit unit)
{
    return info(unit).key;
}

inline bool fromString(const QString &value, InventoryBaseUnit &unit)
{
#define X(name, key, category, factor) \
    if (value == QStringLiteral(key)) { \
        unit = InventoryBaseUnit::name; \
        return true; \
    }
    INVENTORY_BASE_UNITS(X)
#undef X
    return false;
}

inline double convertToBase(double quantity, InventoryBaseUnit from, InventoryBaseUnit base)
{
    const auto& fromInfo = info(from);
    const auto& baseInfo = info(base);

    if (fromInfo.category != baseInfo.category) return -1.0;

    double inCanonical = quantity * fromInfo.toCanonical;
    return inCanonical / baseInfo.toCanonical;
}
