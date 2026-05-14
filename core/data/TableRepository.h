#ifndef TABLEREPOSITORY_H
#define TABLEREPOSITORY_H

#include <QString>
#include <QSqlDatabase>
#include "../domain/Table.h"

class TableRepository
{
public:
    explicit TableRepository(QSqlDatabase db);

    std::vector<Table> getAllTables();
    std::optional<Table> getTableById(int tableId);
    int create(const Table &table);
    void setTableState(int tableId, const QString &status);
    void update(const Table &table);
    void remove(const Table &table);

private:
    QSqlDatabase m_db;
};

#endif // TABLEREPOSITORY_H
