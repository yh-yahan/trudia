#ifndef MEMBERSHIPRESULT_H
#define MEMBERSHIPRESULT_H

#include <QString>

struct RedeemResult {
    int pointsRedeemed = 0;
    int discountCents = 0;
};

struct MembershipResult {
    bool success = false;
    QString error = "";
    int redeemedPoints = 0;
    int earnedPoints = 0;
    double discount = 0;
};

#endif // MEMBERSHIPRESULT_H
