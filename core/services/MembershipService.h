#ifndef MEMBERSHIPSERVICE_H
#define MEMBERSHIPSERVICE_H

#include <QObject>
#include "../data/MembershipRepository.h"
#include "../data/MembershipSettingsRepository.h"
#include "../data/MembershipTransactionRepository.h"

class MembershipService : public QObject
{
    Q_OBJECT

public:
    explicit MembershipService(MembershipRepository &membershipRepo,
                               MembershipSettingsRepository &membershipSettingsRepo,
                               MembershipTransactionRepository &membershipTransactionRepository);

    Q_INVOKABLE QVariantMap getMemberByPhone(const QString &phone);
    Q_INVOKABLE bool createMember(const QString &phone);
    Q_INVOKABLE int calculateEarnedPoints(double orderAmount, const QString &earnOn);
    Q_INVOKABLE double redeemPoints(int memberId, int pointsToRedeem);
    Q_INVOKABLE bool addTransaction(int memberId, int points, const QString &type, int orderSessionId);
    Q_INVOKABLE int getAvailablePoints(int memberId);
    Q_INVOKABLE bool canRedeem(int memberId, int pointsToRedeem);

private:
    MembershipRepository &m_membershipRepo;
    MembershipSettingsRepository &m_membershipSettingsRepo;
    MembershipTransactionRepository &m_membershipTransactionRepository;
};

#endif // MEMBERSHIPSERVICE_H
