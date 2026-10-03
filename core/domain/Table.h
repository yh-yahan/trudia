#ifndef TABLE_H
#define TABLE_H

#include <QString>
#include "../enums/TableStatus.h"

struct Table {
    int id = -1;
    QString table_name;
    int capacity;
    TableStatus status;
    QString created_at;
};

#endif // TABLE_H
