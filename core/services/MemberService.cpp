#include "MemberService.h"

MemberService::MemberService(DatabaseManager &dbManager,
    MembershipRepository &membershipRepo,
    MembershipTransactionRepository &membershipTransactionRepo,
    QObject *parent)
    : QObject(parent),
      m_dbManager(dbManager),
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

bool MemberService::manualAddPoints(int memberId, int points)
{
    if (points <= 0) return false;

    Membership member = m_membershipRepo.getMembershipById(memberId);

    if (member.id <= 0) return false;

    if (member.status == "revoked") return false;

    if (!m_dbManager.beginTransaction()) return false;

    if (!m_membershipRepo.adjustPoints(memberId, "add", points))
    {
        m_dbManager.rollback();
        return false;
    }

    MembershipTransaction txn;
    txn.membership_id = memberId;
    txn.order_session_id = std::nullopt;
    txn.type = "earn";
    txn.points = points;

    if (!m_membershipTransactionRepo.create(txn))
    {
        m_dbManager.rollback();
        return false;
    }

    if (!m_dbManager.commit())
    {
        m_dbManager.rollback();
        return false;
    }

    return true;
}

bool MemberService::manualRedeemPoints(int memberId, int points)
{
    if (points <= 0) return false;

    Membership member = m_membershipRepo.getMembershipById(memberId);

    if (member.id <= 0) return false;

    if (member.status == "revoked") return false;

    if (points > member.total_points) return false;

    if (!m_dbManager.beginTransaction()) return false;

    if (!m_membershipRepo.adjustPoints(memberId, "subtract", points))
    {
        m_dbManager.rollback();
        return false;
    }

    MembershipTransaction txn;
    txn.membership_id = memberId;
    txn.order_session_id = std::nullopt;
    txn.type = "redeem";
    txn.points = points;

    if (!m_membershipTransactionRepo.create(txn))
    {
        m_dbManager.rollback();
        return false;
    }

    if (!m_dbManager.commit())
    {
        m_dbManager.rollback();
        return false;
    }

    return true;
}

bool MemberService::editMember(int memberId, const QString &phoneNumber)
{
    Membership member = m_membershipRepo.getMembershipById(memberId);

    if (member.id <= 0) return false;

    if (member.status == "revoked") return false;

    member.phone_number = phoneNumber;

    return m_membershipRepo.update(member);
}

bool MemberService::revokeMember(int memberId)
{
    Membership member = m_membershipRepo.getMembershipById(memberId);

    if (member.id <= 0) return false;

    member.status = "revoked";

    return m_membershipRepo.update(member);
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
