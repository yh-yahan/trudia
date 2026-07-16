#ifndef MOCKMEMBERSHIPTRANSACTIONREPOSITORY_H
#define MOCKMEMBERSHIPTRANSACTIONREPOSITORY_H

#include "../../core/data/MembershipTransactionRepository.h"
#include "../../core/domain/MembershipTransaction.h"

class MockMembershipTransactionRepository : public MembershipTransactionRepository
{
public:
    MockMembershipTransactionRepository();

    // overridden methods from base class
    bool create(const MembershipTransaction &transaction);

    // test helper methods
    void setCreateResult(bool result);

    // call recording
    int getCreateCallCount() const;
    MembershipTransaction getLastCreatedTransaction() const;

private:
    bool m_createResult = true;

    int m_createCallCount = 0;
    MembershipTransaction m_lastCreatedTransaction;
};

#endif // MOCKMEMBERSHIPTRANSACTIONREPOSITORY_H
