#ifndef MEMBERSHIPSERVICE_H
#define MEMBERSHIPSERVICE_H

#include <QObject>
#include "../domain/Membership.h"
#include "../domain/MembershipResult.h"
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

    MembershipResult applyToOrder(int orderSessionId,
        const QString &phone,
        int orderSubtotalCents,
        int orderTotalCents,
        int requestedRedeemPoints);

    Q_INVOKABLE QVariantMap preview(
        const QString &phone,
        int subtotalCents,
        int totalCents,
        int requestedRedeemPoints);

private:
    MembershipRepository &m_membershipRepo;
    MembershipSettingsRepository &m_membershipSettingsRepo;
    MembershipTransactionRepository &m_membershipTransactionRepository;

    Membership resolveMember(const QString &phone);
    bool createMember(const QString &phone);

    RedeemResult calculateRedemption(const Membership &member, 
        const MembershipSettings &membershipSettings, 
        const int requestedRedeemPoints, 
        const int orderTotalCents);
    int calculateEarning(const MembershipSettings &membershipSettings, 
        const int orderSubtotalCents, 
        const int finalTotalCents);
    
    bool addTransaction(int memberId, 
        int points, 
        const QString &type, 
        int orderSessionId);
};

#endif // MEMBERSHIPSERVICE_H
