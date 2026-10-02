#include "StockMovementRepository.h"

#include <QSqlQuery>
#include <QVariant>

StockMovementRepository::StockMovementRepository(QSqlDatabase db): m_db(db) {}

std::vector<StockMovement> StockMovementRepository::getAll() const
{
    std::vector<StockMovement> movements;

    QSqlQuery query(m_db);
    query.prepare(R"(
        SELECT id, inventory_item_id, quantity, reason,
            idempotency_key, reference_id, note
        FROM stock_movements
        ORDER BY id DESC
    )");

    if (!query.exec()) return movements;

    while (query.next()) {
        StockMovement movement;
        movement.id = query.value("id").toInt();
        movement.inventory_item_id = query.value("inventory_item_id").toInt();
        movement.quantity = query.value("quantity").toInt();
        if (!fromString(query.value("reason").toString(), movement.reason)) continue;
        movement.idempotency_key = query.value("idempotency_key").toString();
        movement.reference_id = query.value("reference_id").toInt();
        movement.note = query.value("note").toString();

        movements.push_back(std::move(movement));
    }

    return movements;
}

std::vector<StockMovement> StockMovementRepository::getByInventoryItemId(int inventoryItemId) const
{
    std::vector<StockMovement> movements;

    QSqlQuery query(m_db);
    query.prepare(R"(
        SELECT id, inventory_item_id, quantity, reason,
            idempotency_key, reference_id, note
        FROM stock_movements
        WHERE inventory_item_id = :inventory_item_id
        ORDER BY id DESC
    )");

    query.bindValue(":inventory_item_id", inventoryItemId);

    if (!query.exec()) return movements;

    while (query.next()) {
        StockMovement movement;
        movement.id = query.value("id").toInt();
        movement.inventory_item_id = query.value("inventory_item_id").toInt();
        movement.quantity = query.value("quantity").toInt();
        if (!fromString(query.value("reason").toString(), movement.reason)) continue;
        movement.idempotency_key = query.value("idempotency_key").toString();
        movement.reference_id = query.value("reference_id").toInt();
        movement.note = query.value("note").toString();

        movements.push_back(std::move(movement));
    }

    return movements;
}

std::optional<StockMovement> StockMovementRepository::getById(int id) const
{
    QSqlQuery query(m_db);
    query.prepare(R"(
        SELECT id, inventory_item_id, quantity, reason,
            idempotency_key, reference_id, note
        FROM stock_movements
        WHERE id = :id
    )");

    query.bindValue(":id", id);

    if (!query.exec() || !query.next()) return std::nullopt;

    StockMovement movement;
    movement.id = query.value("id").toInt();
    movement.inventory_item_id = query.value("inventory_item_id").toInt();
    movement.quantity = query.value("quantity").toInt();
    if (!fromString(query.value("reason").toString(), movement.reason)) return std::nullopt;
    movement.idempotency_key = query.value("idempotency_key").toString();
    movement.reference_id = query.value("reference_id").toInt();
    movement.note = query.value("note").toString();

    return movement;
}

bool StockMovementRepository::getByKey(const QString &key)
{
    QSqlQuery query(m_db);
        query.prepare(R"(
        SELECT 1 FROM stock_movements
        WHERE idempotency_key = :key
        LIMIT 1
    )");

    query.bindValue(":key", key);

    if (!query.exec()) return false;

    return query.next();
}

int StockMovementRepository::sumByReference(int referenceId, int inventoryItemId)
{
    QSqlQuery query(m_db);

    query.prepare(R"(
        SELECT COALESCE(SUM(quantity), 0)
        FROM stock_movements
        WHERE reference_id = :reference_id
        AND inventory_item_id = :inventory_item_id
    )");

    query.bindValue(":reference_id", referenceId);
    query.bindValue(":inventory_item_id", inventoryItemId);

    if (!query.exec() || !query.next()) return 0;

    return query.value(0).toInt();
}

int StockMovementRepository::create(const StockMovement &movement)
{
    QSqlQuery query(m_db);
    query.prepare(R"(
        INSERT INTO stock_movements (
            inventory_item_id, quantity, reason,
            idempotency_key, reference_id, note
        )
        VALUES (
            :inventory_item_id, :quantity, :reason,
            :idempotency_key, :reference_id, :note
        )
    )");

    query.bindValue(":inventory_item_id", movement.inventory_item_id);
    query.bindValue(":quantity", movement.quantity);
    query.bindValue(":reason", toString(movement.reason));
    query.bindValue(":idempotency_key", movement.idempotency_key);
    query.bindValue(":reference_id", movement.reference_id);
    query.bindValue(":note", movement.note);

    if (!query.exec()) return -1;

    return query.lastInsertId().toInt();
}
