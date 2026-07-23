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
    bool setTableState(int tableId, const QString &status);
    void update(const Table &table);
    bool remove(const Table &table);
    bool remove(int tableId);

private:
    QSqlDatabase m_db;
};

#endif // TABLEREPOSITORY_H
