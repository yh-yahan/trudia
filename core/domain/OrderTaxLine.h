#ifndef ORDERTAXLINE_H
#define ORDERTAXLINE_H

#include <QString>

class OrderTaxLine
{
public:
    int id = -1;
    int order_session_id;
    int tax_rule_id;
    QString tax_name_snapshot;
    int rate_snapshot; // scaled integer, with the scale being 1,000,000
    int amount; // stored as the smallest currency unit
    std::optional<QString> created_at;
};

#endif // ORDERTAXLINE_H
