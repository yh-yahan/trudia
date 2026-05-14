#include "TableService.h"

#include "../models/TableModel.h"

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

bool TableService::addTable(const QString &tableName,
                            const int capacity)
{
    if (tableName.trimmed().isEmpty()) {
        qWarning() << "Cannot add empty table name";
        return false;
    }

    if (capacity <= 0) {
        qWarning() << "Capacity must be greater than 0";
        return false;
    }

    Table table;

    table.table_name = tableName.trimmed();
    table.capacity = capacity;
    table.status = "available";

    m_tableRepo.create(table);

    m_tableModel->reload();
    emit tablesChanged();

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

    if (tableName.trimmed().isEmpty()) {
        qWarning() << "Table name cannot be empty";
        return false;
    }

    if (capacity <= 0) {
        qWarning() << "Capacity must be greater than 0";
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
    if (!tableOpt.has_value()) {
        qWarning() << "Table with ID" << tableId << "not found";
        return false;
    }

    m_tableRepo.remove(tableOpt.value());

    m_tableModel->reload();
    emit tablesChanged();

    return true;
}

bool TableService::setTableStatus(const int &tableId,
                                  const QString &status)
{
    auto tableOpt = m_tableRepo.getTableById(tableId);

    if (!tableOpt.has_value()) {
        qWarning() << "Table with ID" << tableId << "not found";
        return false;
    }

    if (status.trimmed().isEmpty()) {
        qWarning() << "Status cannot be empty";
        return false;
    }

    m_tableRepo.setTableState(tableId, status);

    m_tableModel->reload();
    emit tablesChanged();

    return true;
}
