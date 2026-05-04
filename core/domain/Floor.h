#ifndef FLOOR_H
#define FLOOR_H

#include <QString>

class Floor {
public:
    int id = -1;
    QString name;
    int floor_number;
    int sort_order;
    int is_active;
};

#endif // FLOOR_H
