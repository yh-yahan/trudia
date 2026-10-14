#ifndef INVENTORY_H
#define INVENTORY_H

#include <QString>
#include "../enums/InventoryBaseUnit.h"
#include "../enums/InventoryType.h"
#include "../enums/StockMovementReason.h"
#include "../enums/RecipeComponentOwnerType.h"
#include "../enums/RecipeComponentEffect.h"

struct InventoryItem {
    int id = -1;
    QString name;
    InventoryType type;
    InventoryBaseUnit base_unit;
    qint64 quantity;
    int low_quantity;
    QString deleted_at;
    QString sale_paused_at;
};

struct RecipeComponent {
    int id = -1;
    RecipeComponentOwnerType owner_type;
    int owner_id = -1;
    int inventory_item_id = -1;
    qint64 quantity;
    InventoryBaseUnit unit;
    std::optional<int> modifier_id;
    RecipeComponentEffect effect;
    int sort_order;
};

struct StockMovement {
    int id = -1;
    int inventory_item_id = -1;
    int quantity;
    StockMovementReason reason;
    QString idempotency_key;
    int reference_id;
    QString note;
};

#endif // INVENTORY_H
