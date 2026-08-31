#ifndef TABLE_H
#define TABLE_H

#include <QString>

struct Table {
    int id = -1;
    QString table_name;
    int capacity;
    QString status;
    QString created_at;
};

#endif // TABLE_H
