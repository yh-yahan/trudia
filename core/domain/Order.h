#ifndef ORDER_H
#define ORDER_H

#include <QString>

class Order
{
public:
    int id = -1;
    int table_id;
    QString order_type;
    QString status;
    double subtotal;
    double tax;
    double total;
    QString notes;
    QString closed_at;
};

#endif // ORDER_H
