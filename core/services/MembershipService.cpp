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

int MembershipService::calculateEarnedPoints(double orderAmount, const QString &earnOn)
{
    auto settingsOpt = m_membershipSettingsRepo.get();
    if (!settingsOpt.has_value())
        return 0;

    MembershipSettings settings = settingsOpt.value();
    int rate = settings.earn_rate;

    int points = static_cast<int>(std::floor(orderAmount * rate));
    return points;
}

double MembershipService::redeemPoints(int memberId, int pointsToRedeem)
{
    if (!canRedeem(memberId, pointsToRedeem))
    return 0.0;

    auto settingsOpt = m_membershipSettingsRepo.get();
    if (!settingsOpt.has_value())
        return 0.0;

    MembershipSettings settings = settingsOpt.value();

    if (!m_membershipRepo.adjustPoints(memberId, "subtract", pointsToRedeem))
        return 0.0;

    addTransaction(memberId, pointsToRedeem, "redeem", 0);

    double discount = static_cast<double>(pointsToRedeem) / settings.conversion;
    return discount;
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
    int available = getAvailablePoints(memberId);
    auto settingsOpt = m_membershipSettingsRepo.get();

    if (!settingsOpt.has_value())
        return false;

    MembershipSettings settings = settingsOpt.value();

    return available >= pointsToRedeem && pointsToRedeem >= settings.redeem_min_point;
}
