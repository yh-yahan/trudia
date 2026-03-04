#ifndef MEMBERSHIPTRANSACTION_H
#define MEMBERSHIPTRANSACTION_H

#include <QString>

class MembershipTransaction {
public:
    int id = -1;
    int membership_id;
    int order_session_id;
    QString type; // earn/redeem
    int points;
};

#endif // MEMBERSHIPTRANSACTION_H
