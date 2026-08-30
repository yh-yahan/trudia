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

    void testCompleteCheckout_success();
    void testCompleteCheckout_splitPayment();
    void testCompleteCheckout_sessionNotFound();
    void testCompleteCheckout_alreadyPaid();
    void testCompleteCheckout_receiptNumberIncrement();
    void testCompleteCheckout_freesTable();
    void testCompleteCheckout_membership();
    void testCompleteCheckout_snapshotFailureRollback();
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

    QVERIFY(
        helper.checkoutService().recalculateSessionTotals(sessionId)
    );

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

    int sessionId = helper.createTestSession(
        1002,
        "dine_in",
        300
    );

    int orderId = helper.createOrderForSession(sessionId);

    helper.addOrderItem(orderId, coffeeId, 2);
    helper.addOrderItem(orderId, waterId, 1);

    QVERIFY(
        helper.checkoutService().recalculateSessionTotals(sessionId)
    );

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

    QVERIFY(
        helper.checkoutService().recalculateSessionTotals(sessionId)
    );

    auto session = helper.orderSessionRepo().getById(sessionId);
    QVERIFY(session.has_value());

    QCOMPARE(session->subtotal, 100LL);
    QCOMPARE(session->tax, 0LL);
    QCOMPARE(session->total, 0LL);
}

void tst_CheckoutService::testRecalculateSessionTotals_sessionNotFound()
{
    CheckoutServiceTestHelper helper;

    QVERIFY(
        !helper.checkoutService()
            .recalculateSessionTotals(999999)
    );
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

    QVERIFY(
        helper.checkoutService()
            .recalculateSessionTotals(sessionId)
    );

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

    QVERIFY(
        helper.checkoutService()
            .recalculateSessionTotals(sessionId)
    );

    auto session = helper.orderSessionRepo().getById(sessionId);
    QVERIFY(session.has_value());

    QCOMPARE(session->subtotal, 0LL);
    QCOMPARE(session->tax, 0LL);
    QCOMPARE(session->total, 0LL);
}

void tst_CheckoutService::testRecalculateSessionTotals_multipleOrders()
{
    CheckoutServiceTestHelper helper;

    int sessionId =
        helper.createTestSession(
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

    QVERIFY(
        helper.checkoutService()
            .recalculateSessionTotals(sessionId)
    );

    auto session = helper.orderSessionRepo().getById(sessionId);
    QVERIFY(session.has_value());

    QCOMPARE(session->subtotal, 1300LL);
    QCOMPARE(session->tax, 0LL);
    QCOMPARE(session->total, 1300LL);
}

void tst_CheckoutService::testCompleteCheckout_success()
{
    CheckoutServiceTestHelper helper;

    helper.createRestaurant();
    helper.setupTestCashier();
    helper.setReceiptCounter(2026, 1);

    int sessionId = helper.createSessionWithItems(
            1001,
            0,
            {
                {
                    {"name", "Coffee"},
                    {"price", 500},
                    {"quantity", 2},
                    {"taxable", true}
                },
                {
                    {"name", "Water"},
                    {"price", 200},
                    {"quantity", 1},
                    {"taxable", false}
                }
            }
        );

    CheckoutService::CheckoutRequest request{
        sessionId,
        "",
        0,
        {
            {"cash", 1200}
        }
    };

    QVERIFY(
        helper.checkoutService()
            .completeCheckout(request)
    );

    auto sessionOpt = helper.orderSessionRepo().getById(sessionId);

    QVERIFY(sessionOpt.has_value());

    auto session = sessionOpt.value();

    QCOMPARE(session.status, QString("paid"));
    QCOMPARE(session.subtotal, 1200LL);
    QCOMPARE(session.tax, 0LL);
    QCOMPARE(session.total, 1200LL);

    QVERIFY(session.receipt_number.has_value());

    QCOMPARE(
        session.receipt_number.value(),
        QString("2026-000001")
    );

    auto orders = helper.orderRepo().getOrdersBySessionId(sessionId);

    QCOMPARE(orders.size(), 1);
    QCOMPARE(orders[0].status, QString("served"));

    QList<int> orderIds;
    orderIds.append(orders[0].id);

    auto items = helper.orderItemRepo().getOrderItemsByOrderIds(orderIds);

    QCOMPARE(items.size(), 2);

    for (const auto &item : items)
    {
        QCOMPARE(
            item.item_status,
            QString("served")
        );
    }

    auto snapshot = helper.receiptSnapshotRepo().getByOrderSessionId(sessionId);

    QVERIFY(snapshot.has_value());

    QCOMPARE(
        snapshot->store_name,
        QString("Test Restaurant")
    );

    QCOMPARE(
        snapshot->cashier_name,
        QString("cashier")
    );
}

void tst_CheckoutService::testCompleteCheckout_splitPayment()
{
    CheckoutServiceTestHelper helper;

    helper.createRestaurant();
    helper.setupTestCashier();

    int sessionId = helper.createSessionWithItems(
            1001,
            0,
            {
                {
                    {"name", "Coffee"},
                    {"price", 500},
                    {"quantity", 2},
                    {"taxable", true}
                },
                {
                    {"name", "Water"},
                    {"price", 200},
                    {"quantity", 1},
                    {"taxable", false}
                }
            }
        );

    CheckoutService::CheckoutRequest request{
        sessionId,
        "",
        0,
        {
            {"cash", 700},
            {"card", 500}
        }
    };

    QVERIFY(
        helper.checkoutService()
            .completeCheckout(request)
    );

    auto session = helper.orderSessionRepo().getById(sessionId);

    QVERIFY(session.has_value());

    QCOMPARE(session->status, QString("paid"));
    QCOMPARE(session->total, 1200LL);

    auto payments = helper.paymentService().getPaymentsForOrderSession(sessionId);

    QCOMPARE(payments.size(), 2);

    QCOMPARE(
        payments[0].method,
        QString("cash")
    );

    QCOMPARE(
        payments[0].amount,
        700
    );

    QCOMPARE(
        payments[1].method,
        QString("card")
    );

    QCOMPARE(
        payments[1].amount,
        500
    );
}

void tst_CheckoutService::testCompleteCheckout_sessionNotFound()
{
    CheckoutServiceTestHelper helper;

    CheckoutService::CheckoutRequest request{
        999999,
        "",
        0,
        {
            {"cash", 0}
        }
    };

    QVERIFY(
        !helper.checkoutService()
            .completeCheckout(request)
    );
}

void tst_CheckoutService::testCompleteCheckout_alreadyPaid()
{
    CheckoutServiceTestHelper helper;

    helper.createRestaurant();
    helper.setupTestCashier();
    helper.setReceiptCounter(2026, 1);

    int sessionId = helper.createSessionWithItems(
            1001,
            0,
            {
                {
                    {"name", "Coffee"},
                    {"price", 500},
                    {"quantity", 1},
                    {"taxable", false}
                }
            }
        );

    CheckoutService::CheckoutRequest request{
        sessionId,
        "",
        0,
        {
            {"cash", 500}
        }
    };

    QVERIFY(helper.checkoutService().completeCheckout(request));

    auto before = helper.appStateRepo().get("receipt.counter");

    QVERIFY(helper.checkoutService().completeCheckout(request));

    auto after = helper.appStateRepo().get("receipt.counter");

    QCOMPARE(before, after);
}

void tst_CheckoutService::testCompleteCheckout_receiptNumberIncrement()
{
    CheckoutServiceTestHelper helper;

    helper.createRestaurant();
    helper.setupTestCashier();

    helper.setReceiptCounter(2026, 5);

    int session1 = helper.createSessionWithItems();

    CheckoutService::CheckoutRequest request1{
        session1,
        "",
        0,
        {
            {"cash", 0}
        }
    };

    QVERIFY(
        helper.checkoutService()
            .completeCheckout(request1)
    );

    auto first = helper.orderSessionRepo().getById(session1);

    QVERIFY(first.has_value());

    QCOMPARE(
        first->receipt_number.value(),
        QString("2026-000005")
    );

    int session2 = helper.createSessionWithItems(1002);

    CheckoutService::CheckoutRequest request2{
        session2,
        "",
        0,
        {
            {"cash", 0}
        }
    };

    QVERIFY(
        helper.checkoutService()
            .completeCheckout(request2)
    );

    auto second = helper.orderSessionRepo().getById(session2);

    QVERIFY(second.has_value());

    QCOMPARE(
        second->receipt_number.value(),
        QString("2026-000006")
    );
}

void tst_CheckoutService::testCompleteCheckout_freesTable()
{
    CheckoutServiceTestHelper helper;

    helper.createRestaurant();
    helper.setupTestCashier();

    int tableId = helper.createTable(
            "A1",
            TableStatus::Occupied
        );

    int sessionId = helper.createSessionWithItems();

    helper.assignTableToSession(
        sessionId,
        tableId
    );

    CheckoutService::CheckoutRequest request{
        sessionId,
        "",
        0,
        {
            {"cash", 0}
        }
    };

    QVERIFY(helper.checkoutService().completeCheckout(request));

    auto table = helper.tableRepo().getTableById(tableId);

    QVERIFY(table.has_value());

    QCOMPARE(
        table->status,
        TableStatus::Available
    );
}

void tst_CheckoutService::testCompleteCheckout_membership()
{
    CheckoutServiceTestHelper helper;

    helper.createRestaurant();
    helper.setupTestCashier();

    helper.enableMembership(
        true,
        1,
        100,
        "total",
        100,
        100
    );

    helper.createMember(
        "0123456789",
        500
    );

    int sessionId = helper.createSessionWithItems(
            1001,
            0,
            {
                {
                    {"name", "Coffee"},
                    {"price", 1000},
                    {"quantity", 1},
                    {"taxable", false}
                }
            }
        );

    CheckoutService::CheckoutRequest request{
        sessionId,
        "0123456789",
        0,
        {
            {"cash", 1000}
        }
    };

    QVERIFY(
        helper.checkoutService()
            .completeCheckout(request)
    );

    auto session = helper.orderSessionRepo().getById(sessionId);

    QVERIFY(session.has_value());

    QVERIFY(
        session->points_earned > 0
    );
}

void tst_CheckoutService::testCompleteCheckout_snapshotFailureRollback()
{
    CheckoutServiceTestHelper helper;

    helper.setupTestCashier();

    int sessionId = helper.createSessionWithItems();

    CheckoutService::CheckoutRequest request{
        sessionId,
        "",
        0,
        {
            {"cash", 0}
        }
    };

    QVERIFY(
        !helper.checkoutService()
            .completeCheckout(request)
    );

    auto session = helper.orderSessionRepo().getById(sessionId);

    QVERIFY(session.has_value());

    QCOMPARE(
        session->status,
        QString("open")
    );

    QVERIFY(
        !session->receipt_number.has_value()
    );
}

QTEST_MAIN(tst_CheckoutService)
#include "tst_CheckoutService.moc"
