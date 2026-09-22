#ifndef STOCKMOVEMENTREPOSITORY_H
#define STOCKMOVEMENTREPOSITORY_H

#include <QSqlDatabase>
#include <optional>
#include <vector>

#include "../domain/Inventory.h"

class StockMovementRepository
{
public:
    explicit StockMovementRepository(QSqlDatabase db);

    std::vector<StockMovement> getAll() const;
    std::vector<StockMovement> getByInventoryItemId(int inventoryItemId) const;
    std::optional<StockMovement> getById(int id) const;

    int create(const StockMovement &movement);

private:
    QSqlDatabase m_db;
};

#endif // STOCKMOVEMENTREPOSITORY_H
