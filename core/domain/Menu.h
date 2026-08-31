#ifndef MENU_H
#define MENU_H

#include <QString>

struct Menu {
    int id = -1;
    QString item;
    int category_id;
    int price;
    std::optional<QString> portion_size;
    bool is_available;
    bool is_taxable;
};

#endif // MENU_H
