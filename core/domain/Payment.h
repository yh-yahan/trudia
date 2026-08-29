#ifndef PAYMENT_H
#define PAYMENT_H

#include <QString>

class Payment
{
public:
    int id = -1;
    int order_session_id = -1;
    QString method;
    int amount;
    QString type;
    std::optional<int> reverses_payment_id;
    QString created_at;
};

#endif // PAYMENT_H
