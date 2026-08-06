#include "MemberService.h"

MemberService::MemberService(MembershipRepository &membershipRepo,
    MembershipTransactionRepository &membershipTransactionRepo,
    QObject *parent)
    : QObject(parent),
      m_membershipRepo(membershipRepo),
      m_membershipTransactionRepo(membershipTransactionRepo) {}

MemberListModel *MemberService::membersModel()
{
    return &m_membersModel;
}

MemberTransactionModel *MemberService::transactionModel()
{
    return &m_transactionModel;
}

void MemberService::loadMembers()
{
    auto members = m_membershipRepo.getAllMemberships();

    m_membersModel.setMembers(members);
}

void MemberService::searchMembers(const QString &query)
{
    QList<Membership> members;

    if (query.isEmpty())
    {
        members = m_membershipRepo.getAllMemberships();
    }
    else
    {
        members = m_membershipRepo.searchMemberships(query);
    }

    m_membersModel.setMembers(members);
}

QVariantMap MemberService::getMemberDetails(int memberId)
{
    QVariantMap result;

    Membership member = m_membershipRepo.getMembershipById(memberId);

    if (member.id <= 0)
        return result;

    result["id"] = member.id;
    result["phoneNumber"] = member.phone_number;
    result["totalPoints"] = member.total_points;
    result["status"] = member.status;

    return result;
}

void MemberService::loadTransactions(int memberId)
{
    auto transactions = m_membershipTransactionRepo.getTransactionRowsByMembershipId(memberId);

    m_transactionModel.setTransactions(transactions);
}
