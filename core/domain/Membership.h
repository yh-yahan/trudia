#ifndef MEMBERSHIPS_H
#define MEMBERSHIPS_H

#include <QString>

struct Membership {
    int id = -1;
    QString phone_number;
    int total_points;
    QString status; // active/revoked
};

#endif // MEMBERSHIPS_H
