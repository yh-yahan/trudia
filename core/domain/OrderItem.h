#ifndef ORDERITEM_H
#define ORDERITEM_H

#include <QString>

class OrderItem
{
public:
    int id = -1;
    int order_id;
    int item_id;
    QString item_name;
    int quantity;
    QString portion_size;
    double price;
    bool is_taxable;
    QString item_status;
    QString notes;
};

#endif // ORDERITEM_H
