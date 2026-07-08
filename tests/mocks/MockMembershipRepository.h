#ifndef MOCKMEMBERSHIPREPOSITORY_H
#define MOCKMEMBERSHIPREPOSITORY_H

#include "../../core/data/MembershipRepository.h"
#include "../../core/domain/Membership.h"

class MockMembershipRepository : public MembershipRepository
{
public:
    MockMembershipRepository();

    // overridden methods from base class
    Membership getMembershipByPhoneNumber(const QString &phone) override;
    bool create(const Membership &member) override;
    bool adjustPoints(const int &id, const QString &operation, const int &points) override;

    // test helper methods
    void setFakeMember(const Membership &member);
    void setCreateResult(bool result);
    void setAdjustPointsResult(bool result);

    // call recording
    int getAdjustPointsCallCount() const;
    QString getLastAdjustOperation() const;
    int getLastAdjustPoints() const;

private:
    Membership m_fakeMember;
    bool m_createResult = true;
    bool m_adjustPointsResult = true;

    int m_adjustPointsCallCount = 0;
    QString m_lastAdjustOperation;
    int m_lastAdjustPoints = 0;
};

#endif // MOCKMEMBERSHIPREPOSITORY_H
