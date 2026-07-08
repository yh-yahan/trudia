#ifndef MEMBERSHIPTRANSACTIONREPOSITORY_H
#define MEMBERSHIPTRANSACTIONREPOSITORY_H

#include <QString>
#include <QSqlDatabase>
#include "../domain/MembershipTransaction.h"

class MembershipTransactionRepository
{
public:
    explicit MembershipTransactionRepository(QSqlDatabase db);
    virtual ~MembershipTransactionRepository() = default;

    virtual bool create(const MembershipTransaction &transaction);
    MembershipTransaction getById(int id);
    std::vector<MembershipTransaction> getByMembershipId(int membershipId);
    std::vector<MembershipTransaction> getByOrderSessionId(int orderSessionId);
    std::vector<MembershipTransaction> getByType(const QString &type);
    int getPointsByType(int orderSessionId, const QString &type);
    int getMembershipIdBySession(int orderSessionId);
    int getRedeemedPoints(int orderSessionId);
    int getEarnedPoints(int orderSessionId);

private:
    QSqlDatabase m_db;
};

#endif // MEMBERSHIPTRANSACTIONREPOSITORY_H
