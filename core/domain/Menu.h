#ifndef MENU_H
#define MENU_H

#include <QString>

class Menu
{
public:
    int id = -1;
    QString item;
    int category_id;
    double price;
    std::optional<QString> portion_size;
    bool is_available;
    bool is_taxable;
};

#endif // MENU_H
