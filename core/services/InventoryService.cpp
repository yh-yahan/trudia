#include "InventoryService.h"

#include "../logging/LoggingCategories.h"

constexpr qint64 INVENTORY_QUANTITY_SCALE = 1000000;

InventoryService::InventoryService(InventoryItemRepository &inventoryItemRepo,
                                   RecipeComponentRepository &recipeComponentRepo,
                                   StockMovementRepository &stockMovementRepo,
                                   OrderItemRepository &orderItemRepo,
                                   OrderItemModifierRepository &orderItemModifierRepo,
                                   DatabaseManager &databaseManager,
                                   QObject *parent)
    : QObject(parent),
      m_inventoryItemRepo(inventoryItemRepo),
      m_recipeComponentRepo(recipeComponentRepo),
      m_stockMovementRepo(stockMovementRepo),
      m_orderItemRepo(orderItemRepo),
      m_orderItemModifierRepo(orderItemModifierRepo),
      m_databaseManager(databaseManager) {}

QVariantList InventoryService::getItems() const
{
    QVariantList result;

    const auto items = m_inventoryItemRepo.getAll();

    for (const auto &item : items) result.append(toMap(item));

    return result;
}

QVariantMap InventoryService::getItem(int id) const
{
    const auto item = m_inventoryItemRepo.getById(id);

    if (!item) return {};

    return toMap(*item);
}

int InventoryService::createItem(const QVariantMap &data)
{
    const auto item = fromMap(data);

    if (!item) return -1;

    return m_inventoryItemRepo.create(*item);
}

bool InventoryService::updateItem(int id, const QVariantMap &data)
{
    auto item = fromMap(data);

    if (!item) return false;

    item->id = id;

    return m_inventoryItemRepo.update(*item);
}

bool InventoryService::removeItem(int id)
{
    return m_inventoryItemRepo.remove(id);
}

QVariantList InventoryService::getRecipeComponents(const QString &ownerType, int ownerId) const
{
    QVariantList result;

    RecipeComponentOwnerType type;
    if (!fromString(ownerType, type)) return result;

    const auto rows = m_recipeComponentRepo.listByOwner(type, ownerId);

    for (const auto &row : rows) result.append(toMap(row));

    return result;
}

QVariantMap InventoryService::getRecipeComponent(int id) const
{
    const auto row = m_recipeComponentRepo.getById(id);

    if (!row) return {};

    return toMap(*row);
}

int InventoryService::createRecipeComponent(const QVariantMap &data)
{
    const int inventoryItemId = data.value(QStringLiteral("inventoryItemId")).toInt();

    if (inventoryItemId <= 0) return -1;

    const auto item = m_inventoryItemRepo.getById(inventoryItemId);

    if (!item) return -1;

    const auto row = fromRecipeMap(data, item->base_unit);

    if (!row) return -1;

    return m_recipeComponentRepo.create(*row);
}

bool InventoryService::updateRecipeComponent(int id, const QVariantMap &data)
{
    const int inventoryItemId = data.value(QStringLiteral("inventoryItemId")).toInt();

    if (inventoryItemId <= 0) return -1;

    const auto item = m_inventoryItemRepo.getById(inventoryItemId);

    if (!item) return -1;

    auto row = fromRecipeMap(data, item->base_unit);

    if (!row) return false;

    row->id = id;

    return m_recipeComponentRepo.update(*row);
}

bool InventoryService::removeRecipeComponent(int id)
{
    return m_recipeComponentRepo.remove(id);
}

QVariantMap InventoryService::toMap(const InventoryItem &item) const
{
    return {
        { QStringLiteral("id"), item.id },
        { QStringLiteral("name"), item.name },
        { QStringLiteral("type"), toString(item.type) },
        { QStringLiteral("baseUnit"), toString(item.base_unit) },
        { QStringLiteral("quantity"), static_cast<double>(item.quantity) / INVENTORY_QUANTITY_SCALE },
        { QStringLiteral("lowQuantity"), static_cast<double>(item.low_quantity) / INVENTORY_QUANTITY_SCALE },
        { QStringLiteral("deletedAt"), item.deleted_at },
        { QStringLiteral("salePausedAt"), item.sale_paused_at }
    };
}

std::optional<InventoryItem> InventoryService::fromMap(const QVariantMap &data) const
{
    InventoryItem item;

    item.name = data.value(QStringLiteral("name")).toString().trimmed();

    if (item.name.isEmpty()) return std::nullopt;
    if (!fromString(data.value(QStringLiteral("type")).toString(), item.type)) return std::nullopt;
    if (!fromString(data.value(QStringLiteral("baseUnit")).toString(), item.base_unit)) return std::nullopt;

    item.quantity = static_cast<int>(std::round(data.value(QStringLiteral("quantity")).toDouble() * INVENTORY_QUANTITY_SCALE));
    item.low_quantity = static_cast<int>(std::round(data.value(QStringLiteral("lowQuantity")).toDouble() * INVENTORY_QUANTITY_SCALE));
    item.deleted_at = data.value(QStringLiteral("deletedAt")).toString();
    item.sale_paused_at = data.value(QStringLiteral("salePausedAt")).toString();

    return item;
}

QVariantMap InventoryService::toMap(const RecipeComponent &row) const
{
    QVariantMap map{
        { QStringLiteral("id"), row.id },
        { QStringLiteral("ownerType"), toString(row.owner_type) },
        { QStringLiteral("ownerId"), row.owner_id },
        { QStringLiteral("inventoryItemId"), row.inventory_item_id },
        { QStringLiteral("quantity"), static_cast<double>(row.quantity) / INVENTORY_QUANTITY_SCALE },
        { QStringLiteral("unit"), toString(row.unit) },
        { QStringLiteral("effect"), toString(row.effect) },
        { QStringLiteral("sortOrder"), row.sort_order }
    };

    if (row.modifier_id.has_value()) map.insert(QStringLiteral("modifierId"), *row.modifier_id);
    else map.insert(QStringLiteral("modifierId"), QVariant());

    if (const auto item = m_inventoryItemRepo.getById(row.inventory_item_id)) {
        map.insert(QStringLiteral("inventoryItemName"), item->name);
        map.insert(QStringLiteral("baseUnit"), toString(item->base_unit));
    }

    return map;
}

std::optional<RecipeComponent> InventoryService::fromRecipeMap(const QVariantMap &data, const InventoryBaseUnit &baseUnit) const
{
    RecipeComponent row;

    if (!fromString(data.value(QStringLiteral("ownerType")).toString(), row.owner_type)) return std::nullopt;

    row.owner_id = data.value(QStringLiteral("ownerId")).toInt();
    row.inventory_item_id = data.value(QStringLiteral("inventoryItemId")).toInt();

    if (row.owner_id < 0 || row.inventory_item_id < 0) return std::nullopt;

    if (!m_inventoryItemRepo.getById(row.inventory_item_id)) return std::nullopt;

    const QString effect = data.value(QStringLiteral("effect"), QStringLiteral("add")).toString();
    if (!fromString(effect, row.effect)) return std::nullopt;

    row.quantity = static_cast<int>(std::round(data.value(QStringLiteral("quantity")).toDouble() * INVENTORY_QUANTITY_SCALE));

    const QString unitStr = data.value(QStringLiteral("unit")).toString();
    if (unitStr.isEmpty()) {
        // default to the item's base unit if none provided
        row.unit = baseUnit;
    } else {
        if (!fromString(unitStr, row.unit)) return std::nullopt;

        // validate that the unit is compatible with the inventory item's base unit
        if (info(row.unit).category != info(baseUnit).category) return std::nullopt;
    }

    if (row.quantity <= 0) return std::nullopt;

    const QVariant modifier = data.value(QStringLiteral("modifierId"));
    if (modifier.isValid() && !modifier.isNull()) row.modifier_id = modifier.toInt();

    row.sort_order = data.value(QStringLiteral("sortOrder"), 0).toInt();

    return row;
}

bool InventoryService::syncSaleStock(int order_item_id)
{
    if (!m_databaseManager.beginTransaction())
    {
        qCWarning(logInventory) << "Failed to begin transaction";
        return false;
    }

    auto rollback = [&]()
    {
        qCWarning(logInventory) << "Rolling back transaction";
        m_databaseManager.rollback();
        return false;
    };

    const auto orderItemOpt = m_orderItemRepo.getOrderItemById(order_item_id);
    if (!orderItemOpt.has_value()) return rollback();
    const auto &orderItem = orderItemOpt.value();

    std::unordered_map<int, int> selectedModifierQty;
    const auto selectedModifiers = m_orderItemModifierRepo.getByOrderItemId(order_item_id);
    for (const auto &selected : selectedModifiers)
    {
        if (!selected.modifier_id.has_value() || *selected.modifier_id <= 0) continue;
        selectedModifierQty[*selected.modifier_id] += 1;
    }

    const std::vector<RecipeComponent> recipeComponents = m_recipeComponentRepo.listByOwner(RecipeComponentOwnerType::MenuItem, orderItem.item_id);

    auto record = [&](int inventoryItemId, int modifierId, RecipeComponentEffect effect, qint64 expected) -> bool
    {
        const int recorded = m_stockMovementRepo.sumBySaleLine(order_item_id, inventoryItemId, modifierId, toString(effect));
        const int delta = expected - recorded;
        if (delta == 0) return true;

        // sale:{order_item_id}:{inventory_item_id}:{modifier_id}:{effect}:{recorded}:{expected}
        const QString key = QStringLiteral("sale:%1:%2:%3:%4:%5:%6")
                                .arg(order_item_id)
                                .arg(inventoryItemId)
                                .arg(modifierId)
                                .arg(toString(effect))
                                .arg(recorded)
                                .arg(expected);

        if (m_stockMovementRepo.getByKey(key)) return true;

        StockMovement stockMovement;
        stockMovement.inventory_item_id = inventoryItemId;
        stockMovement.quantity = delta;
        stockMovement.reason = StockMovementReason::Sale;
        stockMovement.idempotency_key = key;
        stockMovement.reference_id = order_item_id;
        stockMovement.note = "";

        if (!m_stockMovementRepo.create(stockMovement))
        {
            qCWarning(logInventory) << "Failed to record stock movement";
            return false;
        }

        return m_inventoryItemRepo.updateQuantity(stockMovement.inventory_item_id, stockMovement.quantity);
    };

    auto quantityInBase = [&](const RecipeComponent &component) -> qint64
    {
        auto itemOpt = m_inventoryItemRepo.getById(component.inventory_item_id);
        if (!itemOpt) return 0;

        const double raw = static_cast<double>(component.quantity) / INVENTORY_QUANTITY_SCALE;
        const double converted = convertToBase(raw, component.unit, itemOpt->base_unit);

        return static_cast<qint64>(std::round(converted * INVENTORY_QUANTITY_SCALE));
    };

    std::unordered_map<int, std::vector<RecipeComponent>> replaceByModifier;

    for (const auto &recipeComponent : recipeComponents)
    {
        const bool isModifierLine = recipeComponent.modifier_id.has_value() && *recipeComponent.modifier_id != 0;
        if (!isModifierLine)
        {
            if (recipeComponent.effect != RecipeComponentEffect::Add) continue;

            const qint64 baseQty = quantityInBase(recipeComponent);
            if (!record(recipeComponent.inventory_item_id, 0, RecipeComponentEffect::Add,
                        -(baseQty * orderItem.quantity))) return rollback();
            continue;
        }

        const int modifierId = *recipeComponent.modifier_id;
        const auto selected = selectedModifierQty.find(modifierId);
        if (selected == selectedModifierQty.end()) continue;
        const int scale = orderItem.quantity * selected->second;
        const qint64 baseQty = quantityInBase(recipeComponent);

        if (recipeComponent.effect == RecipeComponentEffect::Add)
        {
            if (!record(recipeComponent.inventory_item_id, modifierId, RecipeComponentEffect::Add,
                        -(baseQty * scale))) return rollback();
        }
        else if (recipeComponent.effect == RecipeComponentEffect::Remove)
        {
            if (!record(recipeComponent.inventory_item_id, modifierId, RecipeComponentEffect::Remove,
                baseQty * scale)) return rollback();
        }
        else if (recipeComponent.effect == RecipeComponentEffect::Replace)
        {
            replaceByModifier[modifierId].push_back(recipeComponent);
        }
    }

    for (auto &entry : replaceByModifier)
    {
        const int modifierId = entry.first;
        const int scale = orderItem.quantity * selectedModifierQty[modifierId];
        auto &rows = entry.second;
        std::sort(rows.begin(), rows.end(), [](const RecipeComponent &a, const RecipeComponent &b)
        {
            if (a.sort_order != b.sort_order) return a.sort_order < b.sort_order;
            return a.id < b.id;
        });

        if (rows.size() % 2 != 0) qCWarning(logInventory) << "Unpaired replace component for modifier" << modifierId;

        for (size_t i = 0; i + 1 < rows.size(); i += 2)
        {
            const qint64 baseQtyA = quantityInBase(rows[i]);
            const qint64 baseQtyB = quantityInBase(rows[i + 1]);

            // rows[i] is the item being replaced, rows[i + 1] is what replaces it.
            if (!record(rows[i].inventory_item_id, modifierId, RecipeComponentEffect::Replace,
                        baseQtyA * scale)) return rollback();
            if (!record(rows[i + 1].inventory_item_id, modifierId, RecipeComponentEffect::Replace,
                        -(baseQtyB * scale))) return rollback();
        }
    }

    if (!m_databaseManager.commit())
    {
        qCWarning(logInventory) << "Commit failed";
        return rollback();
    }

    return true;
}
