#include "MockMembershipRepository.h"

MockMembershipRepository::MockMembershipRepository()
    : MembershipRepository(QSqlDatabase()) {}

Membership MockMembershipRepository::getMembershipByPhoneNumber(const QString &phone)
{
    return m_fakeMember;
}

bool MockMembershipRepository::create(const Membership &member)
{
    return m_createResult;
}

bool MockMembershipRepository::adjustPoints(const int &id, const QString &operation, const int &points)
{
    m_adjustPointsCallCount++;
    m_lastAdjustOperation = operation;
    m_lastAdjustPoints = points;

    return m_adjustPointsResult;
}

// test helpers

void MockMembershipRepository::setFakeMember(const Membership &member)
{
    m_fakeMember = member;
}

void MockMembershipRepository::setCreateResult(bool result)
{
    m_createResult = result;
}

void MockMembershipRepository::setAdjustPointsResult(bool result)
{
    m_adjustPointsResult = result;
}

int MockMembershipRepository::getAdjustPointsCallCount() const
{
    return m_adjustPointsCallCount;
}

QString MockMembershipRepository::getLastAdjustOperation() const
{
    return m_lastAdjustOperation;
}

int MockMembershipRepository::getLastAdjustPoints() const
{
    return m_lastAdjustPoints;
}
