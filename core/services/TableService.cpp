#include "TableService.h"

TableService::TableService(TableRepository &tableRepo): m_tableRepo(tableRepo) {}

QVariantList TableService::getAllTables() const
{
    QVariantList tablesList;

    const auto tables = m_tableRepo.getAllTables();

    for (const auto &table : tables) {
        QVariantMap categoryMap;
        categoryMap["id"] = table.id;
        categoryMap["table_number"] = table.table_number;
        categoryMap["capacity"] = table.capacity;
        categoryMap["is_active"] = table.is_active;

        tablesList.append(categoryMap);
    }

    return tablesList;
}

bool TableService::addTable(const QString &tableName, const int capacity)
{
    if (tableName.trimmed().isEmpty()) {
        qWarning() << "Cannot add empty table name";
        return false;
    }

    if (capacity == NULL) {
        qWarning() << "Cannot add table with empty capacity";
        return false;
    }

    Table table;
    table.table_number = tableName;
    table.capacity = capacity;

    m_tableRepo.create(table);

    return true;
}

bool TableService::editTable(const int &tableId,
               const QString &tableName,
               const int capacity)
{
    auto tableOpt = m_tableRepo.getTableById(tableId);
    if (!tableOpt.has_value()) {
        qWarning() << "Table with ID" << tableId << "not found";
        return false;
    }

    Table &table = tableOpt.value();

    if (!tableName.trimmed().isEmpty()) {
        table.table_number = tableName;
    } else {
        qWarning() << "Table name cannot be empty";
        return false;
    }

    table.capacity = capacity;

    m_tableRepo.update(table);

    return true;
}

bool TableService::removeTable(const int &tableId)
{
    auto tableOpt = m_tableRepo.getTableById(tableId);
    if (!tableOpt.has_value()) {
        qWarning() << "Table with ID" << tableId << "not found";
        return false;
    }

    m_tableRepo.remove(tableOpt.value());

    return true;
}
