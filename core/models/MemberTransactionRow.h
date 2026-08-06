#ifndef MEMBERTRANSACTIONROW_H
#define MEMBERTRANSACTIONROW_H

#include "../domain/MembershipTransaction.h"
#include <QDateTime>

struct TransactionRow
{
    MembershipTransaction transaction;

    int orderDisplayNumber = 0;
    QDateTime created_at;
};

#endif // MEMBERTRANSACTIONROW_H
