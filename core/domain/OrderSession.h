#ifndef ORDERSESSION_H
#define ORDERSESSION_H

#include <QString>

class OrderSession
{
public:
    int id = -1;
    int display_number;
    std::optional<QString> receipt_number;
    std::optional<int> table_id;
    QString order_type;
    QString status;
    int points_earned = 0;
    int points_redeemed = 0;
    double subtotal;
    double tax;
    double discount;
    double total;
    std::optional<QString> opened_at;
    std::optional<QString> closed_at;
};

#endif // ORDERSESSION_H
