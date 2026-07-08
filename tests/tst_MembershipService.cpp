#include <QtTest>
#include "../../core/services/MembershipService.h"

// mocks
#include "mocks/MockMembershipRepository.h"
#include "mocks/MockMembershipSettingsRepository.h"
#include "mocks/MockMembershipTransactionRepository.h"

class tst_MembershipService : public QObject
{
    Q_OBJECT

private slots:
    void initTestCase();
    void cleanupTestCase();

    // preview() tests
    void testPreview_noPhone();
    void testPreview_memberNotFound();
    void testPreview_revokedMember();
    void testPreview_redeemPoints_normal();
    void testPreview_redeemPoints_cappedByOrderTotal();
    void testPreview_earnPoints();

    // applyToOrder() tests
    void testApplyToOrder_redeemAndEarn();
    void testApplyToOrder_revokedMember();
};

void tst_MembershipService::initTestCase()
{
    // global setup here
}

void tst_MembershipService::cleanupTestCase()
{
}

// preview() Tests

void tst_MembershipService::testPreview_noPhone()
{
    MockMembershipRepository memberRepo;
    MockMembershipSettingsRepository settingsRepo;
    MockMembershipTransactionRepository txnRepo;

    MembershipSettings settings;
    settings.enabled = true;
    settings.earn_points = 10;
    settings.earn_spend = 1000;
    settings.earn_on = "subtotal";
    settingsRepo.setFakeSettings(settings);
    settingsRepo.setGetResult(true);

    MembershipService service(memberRepo, settingsRepo, txnRepo);

    auto result = service.preview("", 10000, 10000, 0);

    QVERIFY(!result["success"].toBool());
    QVERIFY(!result["memberFound"].toBool());
    QCOMPARE(result["redeemedPoints"].toInt(), 0);
}

void tst_MembershipService::testPreview_memberNotFound()
{
    MockMembershipRepository memberRepo;
    MockMembershipSettingsRepository settingsRepo;
    MockMembershipTransactionRepository txnRepo;

    MembershipSettings settings;
    settings.enabled = true;
    settings.earn_points = 10;
    settings.earn_spend = 1000;
    settings.earn_on = "subtotal";
    settingsRepo.setFakeSettings(settings);
    settingsRepo.setGetResult(true);

    MembershipService service(memberRepo, settingsRepo, txnRepo);

    auto result = service.preview("9999999999", 10000, 10000, 50);

    QVERIFY(result["success"].toBool());
    QVERIFY(!result["memberFound"].toBool());
}

void tst_MembershipService::testPreview_revokedMember()
{
    MockMembershipRepository memberRepo;
    MockMembershipSettingsRepository settingsRepo;
    MockMembershipTransactionRepository txnRepo;

    Membership member;
    member.id = 1;
    member.phone_number = "0123456789";
    member.total_points = 500;
    member.status = "revoked";
    memberRepo.setFakeMember(member);

    MembershipService service(memberRepo, settingsRepo, txnRepo);

    auto result = service.preview("0123456789", 10000, 10000, 100);

    QVERIFY(!result["success"].toBool());
    QCOMPARE(result["error"].toString(), "MEMBER_REVOKED");
}

void tst_MembershipService::testPreview_redeemPoints_normal()
{
    MockMembershipRepository memberRepo;
    MockMembershipSettingsRepository settingsRepo;
    MockMembershipTransactionRepository txnRepo;

    // setup member
    Membership member;
    member.id = 10;
    member.phone_number = "0123456789";
    member.total_points = 300;
    member.status = "active";
    memberRepo.setFakeMember(member);

    // setup settings (100 points = $5.00)
    MembershipSettings settings;
    settings.enabled = true;
    settings.redeem_points = 100;
    settings.redeem_value = 500;
    settings.earn_points = 10;
    settings.earn_spend = 1000;
    settings.earn_on = "subtotal";
    settingsRepo.setFakeSettings(settings);

    MembershipService service(memberRepo, settingsRepo, txnRepo);

    auto result = service.preview("0123456789", 15000, 15000, 150); // request 150 points

    QVERIFY(result["success"].toBool());
    QCOMPARE(result["redeemedPoints"].toInt(), 150);
    QCOMPARE(result["redeemDiscountCents"].toInt(), 750); // 150 * 5
    QCOMPARE(result["earnedPoints"].toInt(), 150);
    QCOMPARE(result["finalTotalCents"].toInt(), 14250);
}

void tst_MembershipService::testPreview_redeemPoints_cappedByOrderTotal()
{
    MockMembershipRepository memberRepo;
    MockMembershipSettingsRepository settingsRepo;
    MockMembershipTransactionRepository txnRepo;

    Membership member;
    member.id = 1;
    member.total_points = 1000;
    member.status = "active";
    memberRepo.setFakeMember(member);

    MembershipSettings settings;
    settings.redeem_points = 100;
    settings.redeem_value = 1000; // 100 pts = $10
    settings.earn_on = "subtotal";
    settingsRepo.setFakeSettings(settings);

    MembershipService service(memberRepo, settingsRepo, txnRepo);

    auto result = service.preview("0123456789", 2500, 2500, 1000); // request 1000 pts on $25 order

    QCOMPARE(result["redeemedPoints"].toInt(), 250); // capped
    QCOMPARE(result["redeemDiscountCents"].toInt(), 2500);
    QCOMPARE(result["finalTotalCents"].toInt(), 0);
}

void tst_MembershipService::testPreview_earnPoints()
{
    MockMembershipRepository memberRepo;
    MockMembershipSettingsRepository settingsRepo;
    MockMembershipTransactionRepository txnRepo;

    Membership member;
    member.id = 1;
    member.total_points = 100;
    member.status = "active";
    memberRepo.setFakeMember(member);

    MembershipSettings settings;
    settings.enabled = true;
    settings.redeem_points = 100;
    settings.redeem_value = 500;
    settings.earn_points = 10;
    settings.earn_spend = 1000;
    settings.earn_on = "subtotal";
    settingsRepo.setFakeSettings(settings);

    MembershipService service(memberRepo, settingsRepo, txnRepo);

    auto result = service.preview("0123456789", 15000, 15000, 0); // no redemption

    QVERIFY(result["success"].toBool());
    QCOMPARE(result["earnedPoints"].toInt(), 150); // 15000 / 1000 * 10 = 150
}

// applyToOrder() Tests

void tst_MembershipService::testApplyToOrder_redeemAndEarn()
{
    MockMembershipRepository memberRepo;
    MockMembershipSettingsRepository settingsRepo;
    MockMembershipTransactionRepository txnRepo;

    Membership member;
    member.id = 5;
    member.phone_number = "0123456789";
    member.total_points = 400;
    member.status = "active";
    memberRepo.setFakeMember(member);

    MembershipSettings settings;
    settings.enabled = true;
    settings.redeem_points = 100;
    settings.redeem_value = 500;
    settings.earn_points = 10;
    settings.earn_spend = 1000;
    settings.earn_on = "final";
    settingsRepo.setFakeSettings(settings);

    MembershipService service(memberRepo, settingsRepo, txnRepo);

    MembershipResult result = service.applyToOrder(42, "0123456789", 12000, 12000, 200);

    QVERIFY(result.success);
    QCOMPARE(result.redeemedPoints, 200);
    QCOMPARE(result.discount, 1000);
    QCOMPARE(result.earnedPoints, 110); // based on final total after discount

    // verify side effects
    QCOMPARE(memberRepo.getAdjustPointsCallCount(), 2);
    QCOMPARE(txnRepo.getCreateCallCount(), 2);
}

void tst_MembershipService::testApplyToOrder_revokedMember()
{
    MockMembershipRepository memberRepo;
    MockMembershipSettingsRepository settingsRepo;
    MockMembershipTransactionRepository txnRepo;

    Membership member;
    member.id = 1;
    member.status = "revoked";
    memberRepo.setFakeMember(member);

    MembershipService service(memberRepo, settingsRepo, txnRepo);

    MembershipResult result = service.applyToOrder(10, "0123456789", 5000, 5000, 100);

    QVERIFY(!result.success);
    QCOMPARE(result.error, "MEMBER_REVOKED");
}

QTEST_MAIN(tst_MembershipService)
#include "tst_MembershipService.moc"
