#ifndef RECEIPTSNAPSHOT_H
#define RECEIPTSNAPSHOT_H

#include <QString>

class ReceiptSnapshot
{
public:
    int id = -1;
    int order_session_id;
    std::optional<QString> store_name;
    std::optional<QString> address;
    std::optional<QString> phone;
    std::optional<QString> email;
    std::optional<QString> website;

    std::optional<QString> tax_name;
    std::optional<int> tax_rate;
    std::optional<QString> tax_registration_number;

    std::optional<QString> member_phone;
    std::optional<int> points_balance_before;
    std::optional<int> points_balance_after;

    std::optional<QString> order_type;
    std::optional<QString> table_name;
    std::optional<QString> created_at;
};

#endif // RECEIPTSNAPSHOT_H
