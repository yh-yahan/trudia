#include "TableService.h"

#include "../models/TableModel.h"
#include "../logging/LoggingCategories.h"

TableService::TableService(TableRepository &tableRepo, QObject *parent)
    : QObject(parent),
      m_tableRepo(tableRepo)
{
    m_tableModel = new TableModel(m_tableRepo, this);
}

TableModel* TableService::tableModel() const
{
    if (m_tableModel->rowCount() == 0) {
        const_cast<TableModel*>(m_tableModel)->reload();
    }

    return m_tableModel;
}

int TableService::addTable(const QString &tableName,
                            const int capacity)
{
    if (tableName.trimmed().isEmpty()) {
        qCWarning(logFloorPlan) << "Cannot add empty table name";
        return -1;
    }

    if (capacity <= 0) {
        qCWarning(logFloorPlan) << "Capacity must be greater than 0";
        return -1;
    }

    Table table;

    table.table_name = tableName.trimmed();
    table.capacity = capacity;
    table.status = TableStatus::Available;

    int id = m_tableRepo.create(table);

    m_tableModel->reload();
    emit tablesChanged();

    return id;
}

bool TableService::editTable(const int &tableId,
                             const QString &tableName,
                             const int capacity)
{
    auto tableOpt = m_tableRepo.getTableById(tableId);

    if (!tableOpt.has_value()) return false;

    Table &table = tableOpt.value();

    if (tableName.trimmed().isEmpty()) {
        qCWarning(logFloorPlan) << "Table name cannot be empty";
        return false;
    }

    if (capacity <= 0) {
        qCWarning(logFloorPlan) << "Capacity must be greater than 0";
        return false;
    }

    table.table_name = tableName.trimmed();
    table.capacity = capacity;

    m_tableRepo.update(table);

    m_tableModel->reload();
    emit tablesChanged();

    return true;
}

bool TableService::removeTable(const int &tableId)
{
    auto tableOpt = m_tableRepo.getTableById(tableId);
    if (!tableOpt.has_value()) return false;

    m_tableRepo.remove(tableOpt.value());

    m_tableModel->reload();
    emit tablesChanged();

    return true;
}

bool TableService::setTableStatus(const int &tableId, const TableStatus &status)
{
    m_tableRepo.setTableState(tableId, status);
    m_tableModel->reload();
    
    emit tableStatusChanged(tableId, toString(status));
    emit tablesChanged();

    return true;
}
