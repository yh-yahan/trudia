#include "MemberService.h"

MemberService::MemberService(MembershipRepository &membershipRepository, QObject *parent)
    : QObject(parent),
      m_membershipRepository(membershipRepository) {}

MemberListModel *MemberService::membersModel()
{
    return &m_membersModel;
}

void MemberService::loadMembers()
{
    auto members = m_membershipRepository.getAllMemberships();

    m_membersModel.setMembers(members);
}

void MemberService::searchMembers(const QString &query)
{
    QList<Membership> members;

    if (query.isEmpty())
    {
        members = m_membershipRepository.getAllMemberships();
    }
    else
    {
        members = m_membershipRepository.searchMemberships(query);
    }

    m_membersModel.setMembers(members);
}
