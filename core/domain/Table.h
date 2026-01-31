#ifndef TABLE_H
#define TABLE_H

#include <QString>

class Table
{
public:
    int id = -1;
    QString table_number;
    std::optional<int> capacity;
    bool is_active;
};

#endif // TABLE_H
