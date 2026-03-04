#ifndef MEMBERSHIPREPOSITORY_H
#define MEMBERSHIPREPOSITORY_H

#include <QString>
#include <QSqlDatabase>
#include "../domain/Membership.h"

class MembershipRepository
{
public:
    explicit MembershipRepository(QSqlDatabase db);

    bool create(const Membership &membership);
    Membership getMembershipById(const int &id);
    Membership getMembershipByPhoneNumber(const QString &phoneNumber);
    QList<Membership> getAllMemberships();
    bool update(const Membership &membership);
    bool adjustPoints(const int &id, const QString &operation, const int &points); // operation => add/subtract
    QList<Membership> getMembershipsByStatus(const QString &status);
    bool remove(const int &id);

private:
    QSqlDatabase m_db;
};

#endif // MEMBERSHIPREPOSITORY_H
