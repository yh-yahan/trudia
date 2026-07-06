#ifndef MEMBERSHIPSETTINGS_H
#define MEMBERSHIPSETTINGS_H

#include <QString>

class MembershipSettings
{
public:
    int id = -1;
    bool enabled = false;
    int earn_points = 0;
    int earn_spend = 0;
    int redeem_points = 0;
    int redeem_value = 0;
    QString earn_on;
};

#endif // MEMBERSHIPSETTINGS_H
