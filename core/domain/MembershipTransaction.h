#ifndef MEMBERSHIPTRANSACTION_H
#define MEMBERSHIPTRANSACTION_H

#include <QString>

struct MembershipTransaction {
    int id = -1;
    int membership_id;
    std::optional<int> order_session_id;
    QString type; // earn/redeem
    int points;
};

#endif // MEMBERSHIPTRANSACTION_H
