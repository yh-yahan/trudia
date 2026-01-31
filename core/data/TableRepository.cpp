#include "TableRepository.h"

#include <QSqlQuery>
#include <QSqlError>
#include <QVariant>
#include <QDebug>

TableRepository::TableRepository(QSqlDatabase db): m_db(db) {}

std::vector<Table> TableRepository::getAllTables()
{
    std::vector<Table> tables;

    QSqlQuery query(m_db);
    query.prepare("SELECT id, table_number, capacity, is_active FROM tables");

    if (!query.exec()) {
        qWarning() << "getAllTables failed:" << query.lastError();
        return tables;
    }

    while (query.next()) {
        Table table;
        table.id = query.value("id").toInt();
        table.table_number = query.value("table_number").toString();
        table.capacity = query.value("capacity").toInt();
        table.is_active = query.value("is_active").toBool();

        tables.push_back(table);
    }

    return tables;
}

std::optional<Table> TableRepository::getTableById(int tableId)
{
    QSqlQuery query(m_db);
    query.prepare("SELECT id, table_number, capacity, is_active FROM tables WHERE id = :id");
    query.bindValue(":id", tableId);

    if (!query.exec()) {
        qWarning() << "getTableById failed:" << query.lastError();
        return std::nullopt;
    }

    if (!query.next()) {
        return std::nullopt;
    }

    Table table;
    table.id = query.value("id").toInt();
    table.table_number = query.value("table_number").toString();
    table.capacity = query.value("capacity").toInt();
    table.is_active = query.value("is_active").toBool();

    return table;
}

void TableRepository::create (const Table &table)
{
    QSqlQuery query(m_db);
    query.prepare(R"(
        INSERT INTO tables (table_number, capacity, is_active)
        VALUES (:table_number, :capacity, false)
    )");

    query.bindValue(":table_number", table.table_number);
    query.bindValue(":capacity", table.capacity);

    if (!query.exec()) {
        qWarning() << "create failed:" << query.lastError();
    }
}

void TableRepository::update(const Table &table)
{
    QSqlQuery query(m_db);
    query.prepare(R"(
        UPDATE tables
        SET table_number = :table_number, capacity = :capacity
        WHERE id = :table_id
    )");

    query.bindValue(":table_id", table.id);
    query.bindValue(":table_number", table.table_number);
    query.bindValue(":capacity", table.capacity);

    if (!query.exec()) {
        qWarning() << "update failed:" << query.lastError();
    }
}

void TableRepository::remove(const Table &table)
{
    QSqlQuery query(m_db);
    query.prepare(R"(
        DELETE FROM tables
        WHERE id = :table_id
    )");

    query.bindValue(":table_id", table.id);

    if (!query.exec()) {
        qWarning() << "remove failed:" << query.lastError();
    }
}
