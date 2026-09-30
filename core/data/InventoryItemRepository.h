#ifndef INVENTORYITEMREPOSITORY_H
#define INVENTORYITEMREPOSITORY_H

#include <QSqlDatabase>
#include <optional>
#include <vector>
#include "../domain/Inventory.h"

class InventoryItemRepository
{
public:
    explicit InventoryItemRepository(QSqlDatabase db);

    std::vector<InventoryItem> getAll() const;
    std::optional<InventoryItem> getById(int id) const;

    int create(const InventoryItem &item);
    bool update(const InventoryItem &item);
    bool updateQuantity(int id, int delta);
    bool remove(int id);

private:
    QSqlDatabase m_db;
};

#endif // INVENTORYITEMREPOSITORY_H
