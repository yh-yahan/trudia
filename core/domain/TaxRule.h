#ifndef TAXRULE_H
#define TAXRULE_H

#include <QString>

class TaxRule
{
public:
    int id = -1;
    QString name;
    int rate; // scaled integer, with the scale being 1,000,000
    QString scope; // item/order
    QString apply_to; // all/taxable_only
    int priority;
    bool active;
    QString created_at;
};

#endif // TAXRULE_H
