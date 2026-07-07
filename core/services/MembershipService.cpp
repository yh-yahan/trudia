#include "MembershipService.h"

MembershipService::MembershipService(MembershipRepository &membershipRepo,
                MembershipSettingsRepository &membershipSettingsRepo,
                MembershipTransactionRepository &membershipTransactionRepository) : 
                m_membershipRepo(membershipRepo),
                m_membershipSettingsRepo(membershipSettingsRepo),
                m_membershipTransactionRepository(membershipTransactionRepository) {}

MembershipResult MembershipService::applyToOrder(int orderSessionId, const QString &phone,
    int orderSubtotalCents, 
    int orderTotalCents, 
    int requestedRedeemPoints)
{
    // resolve & validate member
    Membership member = resolveMember(phone);
    if (member.status == "revoked") return MembershipResult{false, "MEMBER_REVOKED"};

    // get membership settings
    auto membershipSettingsOpt = m_membershipSettingsRepo.get();
    if (!membershipSettingsOpt.has_value())
    {
        return MembershipResult{false, "MEMBERSHIP_SETTINGS_NOT_FOUND"};
    }

    const MembershipSettings &membershipSettings = membershipSettingsOpt.value();

    // calculate redeem points
    auto redeem = calculateRedemption(member, membershipSettings, requestedRedeemPoints, orderTotalCents);

    int finalTotal = orderTotalCents - redeem.discountCents;

    // calculate earn points
    int earnedPoints = calculateEarning(membershipSettings, orderSubtotalCents, finalTotal);

    // add transaction & update member total points
    if (redeem.pointsRedeemed > 0)
    {
        m_membershipRepo.adjustPoints(member.id, "subtract", redeem.pointsRedeemed);

        addTransaction(member.id, redeem.pointsRedeemed, "redeem", orderSessionId);
    }

    if (earnedPoints > 0)
    {
        m_membershipRepo.adjustPoints(member.id, "add", earnedPoints);

        addTransaction(member.id, earnedPoints, "earn", orderSessionId);
    }

    // build & return membership result
    MembershipResult membershipResult;
    membershipResult.success = true;
    membershipResult.error = "";
    membershipResult.redeemedPoints = redeem.pointsRedeemed;
    membershipResult.earnedPoints = earnedPoints;
    membershipResult.discount = redeem.discountCents;

    return membershipResult;
}

QVariantMap MembershipService::preview(
    const QString &phone,
    int subtotalCents,
    int totalCents,
    int requestedRedeemPoints)
{
    QVariantMap result;

    result["success"] = false;
    result["memberFound"] = false;
    result["memberId"] = 0;
    result["currentPoints"] = 0;
    result["redeemedPoints"] = 0;
    result["redeemDiscountCents"] = 0;
    result["earnedPoints"] = 0;
    result["finalTotalCents"] = totalCents;

    if (phone.isEmpty())
        return result;

    Membership member = m_membershipRepo.getMembershipByPhoneNumber(phone);

    bool memberFound = member.id > 0;

    result["memberFound"] = memberFound;

    if (memberFound)
    {
        result["memberId"] = member.id;
        result["currentPoints"] = member.total_points;

        if (member.status == "revoked")
        {
            result["error"] = "MEMBER_REVOKED";
            return result;
        }
    }

    auto settingsOpt = m_membershipSettingsRepo.get();

    if (!settingsOpt.has_value())
    {
        result["error"] = "MEMBERSHIP_SETTINGS_NOT_FOUND";
        return result;
    }

    const MembershipSettings &settings = settingsOpt.value();

    RedeemResult redeem;

    if (memberFound)
    {
        redeem = calculateRedemption(
            member,
            settings,
            requestedRedeemPoints,
            totalCents);
    }

    int finalTotal = totalCents - redeem.discountCents;

    int earnedPoints = calculateEarning(settings, subtotalCents, finalTotal);

    result["success"] = true;
    result["redeemedPoints"] = redeem.pointsRedeemed;
    result["redeemDiscountCents"] = redeem.discountCents;
    result["earnedPoints"] = earnedPoints;
    result["finalTotalCents"] = finalTotal;

    return result;
}

Membership MembershipService::resolveMember(const QString &phone)
{
    Membership member = m_membershipRepo.getMembershipByPhoneNumber(phone);

    if (member.id <= 0)
    {
        if (createMember(phone))
        {
            member = m_membershipRepo.getMembershipByPhoneNumber(phone);
        }
    }

    return member;
}

RedeemResult MembershipService::calculateRedemption(const Membership &member, 
    const MembershipSettings &membershipSettings, 
    const int requestedRedeemPoints, 
    const int orderTotalCents)
{
    RedeemResult result;

    if (requestedRedeemPoints <= 0) return result;
    if (membershipSettings.redeem_points <= 0 || membershipSettings.redeem_value <= 0) return result;
    if (member.total_points <= 0) return result;

    int points = std::min(requestedRedeemPoints, member.total_points);

    int discountCents = (points * membershipSettings.redeem_value) / membershipSettings.redeem_points;

    if (discountCents > orderTotalCents)
    {
        discountCents = orderTotalCents;

        // adjust points so they match the capped discount
        points = (discountCents * membershipSettings.redeem_points) / membershipSettings.redeem_value;
    }

    result.pointsRedeemed = points;
    result.discountCents = discountCents;

    return result;
}

int MembershipService::calculateEarning(const MembershipSettings &membershipSettings, 
    const int orderSubtotalCents, const int finalTotalCents)
{
    if (!membershipSettings.enabled) return 0;
    if (membershipSettings.earn_points <= 0 || membershipSettings.earn_spend <= 0) return 0;

    int baseAmount = (membershipSettings.earn_on == "subtotal")
            ? orderSubtotalCents
            : finalTotalCents;

    int pointsEarned = (baseAmount / membershipSettings.earn_spend) * membershipSettings.earn_points;

    return pointsEarned;
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

bool MembershipService::addTransaction(int memberId, int points, const QString &type, int orderSessionId)
{
    MembershipTransaction txn;
    txn.membership_id = memberId;
    txn.points = points;
    txn.type = type;
    txn.order_session_id = orderSessionId;

    return m_membershipTransactionRepository.create(txn);
}
