#ifndef MEMBERSHIPSETTINGS_H
#define MEMBERSHIPSETTINGS_H

#include <QString>

class MembershipSettings
{
public:
    int id = -1;
    bool enabled;
    int earn_rate;
    int min_spend; // scaled to cents
    QString earn_on; // subtotal/total
    int conversion; // x points = RM1
    int redeem_min_point; // minimum points to redeem
    bool partial_redemption;
    std::optional<QString> created_at;
};

#endif // MEMBERSHIPSETTINGS_H
