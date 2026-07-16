#include <QtTest>
#include "CheckoutServiceTestHelper.h"

class tst_CheckoutService : public QObject
{
    Q_OBJECT

private slots:
    void testRecalculateSessionTotals_basic();
    void testRecalculateSessionTotals_withDiscountAndTax();
    void testRecalculateSessionTotals_negativeTotalCapped();

    void testRecalculateSessionTotals_sessionNotFound();
    void testRecalculateSessionTotals_taxOnlyAppliesToTaxableItems();
    void testRecalculateSessionTotals_emptySession();
    void testRecalculateSessionTotals_multipleOrders();
};

void tst_CheckoutService::testRecalculateSessionTotals_basic()
{
    CheckoutServiceTestHelper helper;

    int coffeeId = helper.createMenuItem("Coffee", 500, true);
    int waterId = helper.createMenuItem("Water", 200, false);

    int sessionId = helper.createTestSession(1001, "dine_in", 0);

    int orderId = helper.createOrderForSession(sessionId);

    helper.addOrderItem(orderId, coffeeId, 2);
    helper.addOrderItem(orderId, waterId, 1);

    QVERIFY(helper.checkoutService().recalculateSessionTotals(sessionId));

    auto session = helper.orderSessionRepo().getById(sessionId);
    QVERIFY(session.has_value());

    QCOMPARE(session->subtotal, 1200LL);
    QCOMPARE(session->tax, 0LL);
    QCOMPARE(session->total, 1200LL);
}

void tst_CheckoutService::testRecalculateSessionTotals_withDiscountAndTax()
{
    CheckoutServiceTestHelper helper;

    helper.setTaxSettings(true, 1000); // 10%

    int coffeeId = helper.createMenuItem("Coffee", 500, true);
    int waterId = helper.createMenuItem("Water", 200, false);

    int sessionId = helper.createTestSession(1002, "dine_in", 300);

    int orderId = helper.createOrderForSession(sessionId);

    helper.addOrderItem(orderId, coffeeId, 2);
    helper.addOrderItem(orderId, waterId, 1);

    QVERIFY(helper.checkoutService().recalculateSessionTotals(sessionId));

    auto session = helper.orderSessionRepo().getById(sessionId);
    QVERIFY(session.has_value());

    // taxable subtotal = 1000
    // tax = 100
    // total = 1200 + 100 - 300 = 1000
    QCOMPARE(session->subtotal, 1200LL);
    QCOMPARE(session->tax, 100LL);
    QCOMPARE(session->total, 1000LL);
}

void tst_CheckoutService::testRecalculateSessionTotals_negativeTotalCapped()
{
    CheckoutServiceTestHelper helper;

    int coffeeId = helper.createMenuItem("Coffee", 100, true);

    int sessionId = helper.createTestSession(1003, "dine_in", 5000);

    int orderId = helper.createOrderForSession(sessionId);

    helper.addOrderItem(orderId, coffeeId, 1);

    QVERIFY(helper.checkoutService().recalculateSessionTotals(sessionId));

    auto session = helper.orderSessionRepo().getById(sessionId);
    QVERIFY(session.has_value());

    QCOMPARE(session->subtotal, 100LL);
    QCOMPARE(session->tax, 0LL);
    QCOMPARE(session->total, 0LL);
}

void tst_CheckoutService::testRecalculateSessionTotals_sessionNotFound()
{
    CheckoutServiceTestHelper helper;

    QVERIFY(!helper.checkoutService().recalculateSessionTotals(999999));
}

void tst_CheckoutService::testRecalculateSessionTotals_taxOnlyAppliesToTaxableItems()
{
    CheckoutServiceTestHelper helper;

    helper.setTaxSettings(true, 1000); // 10%

    int taxableId = helper.createMenuItem("Taxable", 100, true);

    int nonTaxableId = helper.createMenuItem("Non-taxable", 900, false);

    int sessionId = helper.createTestSession(1004, "dine_in", 0);

    int orderId = helper.createOrderForSession(sessionId);

    helper.addOrderItem(orderId, taxableId, 1);
    helper.addOrderItem(orderId, nonTaxableId, 1);

    QVERIFY(helper.checkoutService().recalculateSessionTotals(sessionId));

    auto session = helper.orderSessionRepo().getById(sessionId);
    QVERIFY(session.has_value());

    QCOMPARE(session->subtotal, 1000LL);
    QCOMPARE(session->tax, 10LL);
    QCOMPARE(session->total, 1010LL);
}

void tst_CheckoutService::testRecalculateSessionTotals_emptySession()
{
    CheckoutServiceTestHelper helper;

    int sessionId = helper.createTestSession(
        1005,
        "dine_in",
        0
    );

    QVERIFY(helper.checkoutService().recalculateSessionTotals(sessionId));

    auto session = helper.orderSessionRepo().getById(sessionId);
    QVERIFY(session.has_value());

    QCOMPARE(session->subtotal, 0LL);
    QCOMPARE(session->tax, 0LL);
    QCOMPARE(session->total, 0LL);
}

void tst_CheckoutService::testRecalculateSessionTotals_multipleOrders()
{
    CheckoutServiceTestHelper helper;

    int sessionId = helper.createTestSession(
        1006,
        "dine_in",
        0
    );

    int order1 = helper.createOrderForSession(sessionId, 1);
    int order2 = helper.createOrderForSession(sessionId, 2);

    int coffeeId = helper.createMenuItem("Coffee", 500, true);
    int teaId = helper.createMenuItem("Tea", 300, true);

    helper.addOrderItem(order1, coffeeId, 2);
    helper.addOrderItem(order2, teaId, 1);

    QVERIFY(helper.checkoutService().recalculateSessionTotals(sessionId));

    auto session = helper.orderSessionRepo().getById(sessionId);
    QVERIFY(session.has_value());

    QCOMPARE(session->subtotal, 1300LL);
    QCOMPARE(session->tax, 0LL);
    QCOMPARE(session->total, 1300LL);
}

QTEST_MAIN(tst_CheckoutService)
#include "tst_CheckoutService.moc"
