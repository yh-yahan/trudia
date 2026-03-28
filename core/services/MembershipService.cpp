#include "MembershipService.h"

MembershipService::MembershipService(MembershipRepository &membershipRepo,
                MembershipSettingsRepository &membershipSettingsRepo,
                MembershipTransactionRepository &membershipTransactionRepository) : 
                m_membershipRepo(membershipRepo),
                m_membershipSettingsRepo(membershipSettingsRepo),
                m_membershipTransactionRepository(membershipTransactionRepository) {}

QVariantMap MembershipService::getMemberByPhone(const QString &phone)
{
    QVariantMap result;
    Membership member = m_membershipRepo.getMembershipByPhoneNumber(phone);

    if (member.id > 0) {
        result["id"] = member.id;
        result["phone_number"] = member.phone_number;
        result["total_points"] = member.total_points;
        result["status"] = member.status;
    }

    return result;
}

bool MembershipService::createMember(const QString &phone)
{
    Membership member = m_membershipRepo.getMembershipByPhoneNumber(phone);
    if (member.id > 0) {
        return true;
    }

    Membership newMember;
    newMember.phone_number = phone;
    newMember.total_points = 0;
    newMember.status = "active";

    return m_membershipRepo.create(newMember);
}

int MembershipService::calculateEarnedPoints(int subtotalCents, int totalCents)
{
    auto settingsOpt = m_membershipSettingsRepo.get();
    if (!settingsOpt.has_value())
        return 0;

    const auto &s = settingsOpt.value();

    if (!s.enabled || s.earn_spend <= 0)
        return 0;

    int baseAmount = (s.earn_on == "subtotal")
            ? subtotalCents
            : totalCents;

    return (baseAmount / s.earn_spend) * s.earn_points;
}

double MembershipService::redeemPoints(int memberId, int pointsToRedeem)
{
    if (!canRedeem(memberId, pointsToRedeem))
        return 0.0;

    auto settingsOpt = m_membershipSettingsRepo.get();
    if (!settingsOpt.has_value())
        return 0.0;

    const MembershipSettings &s = settingsOpt.value();

    if (s.redeem_points <= 0)
        return 0.0;

    int discountCents = (pointsToRedeem * s.redeem_value) / s.redeem_points;

    if (!m_membershipRepo.adjustPoints(memberId, "subtract", pointsToRedeem))
        return 0.0;

    addTransaction(memberId, pointsToRedeem, "redeem", 0);

    return discountCents / 100.0;
}

bool MembershipService::addTransaction(int memberId, int points, const QString &type, int orderSessionId)
{
    MembershipTransaction txn;
    txn.membership_id = memberId;
    txn.points = points;
    txn.type = type;
    txn.order_session_id = orderSessionId;

    return m_membershipTransactionRepository.create(txn);
}

int MembershipService::getAvailablePoints(int memberId)
{
    Membership member = m_membershipRepo.getMembershipById(memberId);
    return member.id > 0 ? member.total_points : 0;
}

bool MembershipService::canRedeem(int memberId, int pointsToRedeem)
{
    if (pointsToRedeem <= 0)
        return false;

    int available = getAvailablePoints(memberId);
    return available >= pointsToRedeem;
}
