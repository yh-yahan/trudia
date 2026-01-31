#ifndef TABLEREPOSITORY_H
#define TABLEREPOSITORY_H

#include <QString>
#include <QSqlDatabase>
#include "../domain/Table.h"

class TableRepository
{
public:
    explicit TableRepository(QSqlDatabase db);

    void createTable (const Table &table);

private:
    QSqlDatabase m_db;
};

#endif // TABLEREPOSITORY_H
