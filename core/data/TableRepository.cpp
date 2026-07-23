#include "TableRepository.h"

#include <QSqlQuery>
#include <QSqlError>
#include <QVariant>
#include "../logging/LoggingCategories.h"

TableRepository::TableRepository(QSqlDatabase db)
    : m_db(db) {}

std::vector<Table> TableRepository::getAllTables()
{
    std::vector<Table> tables;

    QSqlQuery query(m_db);
    query.prepare(R"(
        SELECT id, table_name, capacity, status, created_at
        FROM tables
    )");

    if (!query.exec()) {
        qCWarning(logDatabase) << "getAllTables failed:" << query.lastError();
        return tables;
    }

    while (query.next()) {
        Table table;

        table.id = query.value("id").toInt();
        table.table_name = query.value("table_name").toString();
        table.capacity = query.value("capacity").toInt();
        table.status = query.value("status").toString();
        table.created_at = query.value("created_at").toString();

        tables.push_back(table);
    }

    return tables;
}

std::optional<Table> TableRepository::getTableById(int tableId)
{
    QSqlQuery query(m_db);

    query.prepare(R"(
        SELECT id, table_name, capacity, status, created_at
        FROM tables
        WHERE id = :id
    )");

    query.bindValue(":id", tableId);

    if (!query.exec()) {
        qCWarning(logDatabase) << "getTableById failed:" << query.lastError();
        return std::nullopt;
    }

    if (!query.next()) {
        return std::nullopt;
    }

    Table table;

    table.id = query.value("id").toInt();
    table.table_name = query.value("table_name").toString();
    table.capacity = query.value("capacity").toInt();
    table.status = query.value("status").toString();
    table.created_at = query.value("created_at").toString();

    return table;
}

int TableRepository::create(const Table &table)
{
    QSqlQuery query(m_db);
    query.prepare(R"(
        INSERT INTO tables (
            table_name,
            capacity,
            status
        )
        VALUES (
            :table_name,
            :capacity,
            :status
        )
    )");

    query.bindValue(":table_name", table.table_name);
    query.bindValue(":capacity", table.capacity);
    query.bindValue(":status", table.status);

    if (!query.exec()) {
        qCWarning(logDatabase) << "create failed:" << query.lastError();
    }

    return query.lastInsertId().toInt();
}

void TableRepository::update(const Table &table)
{
    QSqlQuery query(m_db);

    query.prepare(R"(
        UPDATE tables
        SET
            table_name = :table_name,
            capacity = :capacity,
            status = :status
        WHERE id = :table_id
    )");

    query.bindValue(":table_id", table.id);
    query.bindValue(":table_name", table.table_name);
    query.bindValue(":capacity", table.capacity);
    query.bindValue(":status", table.status);

    if (!query.exec()) {
        qCWarning(logDatabase) << "update failed:" << query.lastError();
    }
}

bool TableRepository::setTableState(int tableId, const QString &status)
{
    QSqlQuery query(m_db);

    query.prepare(R"(
        UPDATE tables
        SET status = :status
        WHERE id = :table_id
    )");

    query.bindValue(":table_id", tableId);
    query.bindValue(":status", status);

    if (!query.exec()) {
        qCWarning(logDatabase) << "setTableState failed:" << query.lastError();
        return false;
    }

    return true;
}

bool TableRepository::remove(const Table &table)
{
    return remove(table.id);
}

bool TableRepository::remove(int tableId)
{
    QSqlQuery query(m_db);

    query.prepare(R"(
        DELETE FROM tables
        WHERE id = :table_id
    )");

    query.bindValue(":table_id", tableId);

    if (!query.exec()) {
        qCWarning(logDatabase) << "remove failed:" << query.lastError();
        return false;
    }

    return true;
}
