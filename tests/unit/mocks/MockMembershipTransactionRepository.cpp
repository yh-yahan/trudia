#include "MockMembershipTransactionRepository.h"

MockMembershipTransactionRepository::MockMembershipTransactionRepository()
    : MembershipTransactionRepository(QSqlDatabase()) {}

bool MockMembershipTransactionRepository::create(
    const MembershipTransaction &transaction)
{
    m_createCallCount++;
    m_lastCreatedTransaction = transaction;

    return m_createResult;
}

// test helper methods

void MockMembershipTransactionRepository::setCreateResult(bool result)
{
    m_createResult = result;
}

// call recording

int MockMembershipTransactionRepository::getCreateCallCount() const
{
    return m_createCallCount;
}

MembershipTransaction MockMembershipTransactionRepository::getLastCreatedTransaction() const
{
    return m_lastCreatedTransaction;
}
