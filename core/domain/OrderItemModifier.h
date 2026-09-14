#ifndef ORDERITEMMODIFIER_H
#define ORDERITEMMODIFIER_H

#include <QString>

struct OrderItemModifier {
    int id = -1;
    int order_item_id = -1;
    std::optional<int> modifier_id = -1;
    std::optional<int> group_id = -1;
    QString group_name;
    QString name;
    int price_delta;
};

#endif // ORDERITEMMODIFIER_H
