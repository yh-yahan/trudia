#include "InventoryService.h"

constexpr int INVENTORY_QUANTITY_SCALE = 1000;

InventoryService::InventoryService(InventoryItemRepository inventoryItemRepo,
                                   QObject *parent)
    : QObject(parent),
      m_inventoryItemRepo(inventoryItemRepo) {}

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

    item.quantity = static_cast<int>(std::round(
        data.value(QStringLiteral("quantity")).toDouble()
        * INVENTORY_QUANTITY_SCALE
    ));
    item.low_quantity = static_cast<int>(std::round(
        data.value(QStringLiteral("lowQuantity")).toDouble()
        * INVENTORY_QUANTITY_SCALE
    ));
    item.deleted_at = data.value(QStringLiteral("deletedAt"), true).toString();
    item.sale_paused_at = data.value(QStringLiteral("salePausedAt"), false).toString();

    return item;
}
