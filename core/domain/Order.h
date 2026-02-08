#ifndef ORDER_H
#define ORDER_H

#include <QString>

class Order
{
public:
    int id = -1;
    int order_session_id;
    int display_number;
    QString status;
    QString notes;
    QString closed_at;
};

#endif // ORDER_H
