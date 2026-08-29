#include "PaymentRepository.h"

#include <QSqlQuery>
#include <QVariant>

PaymentRepository::PaymentRepository(QSqlDatabase db) : m_db(db) {}

std::optional<Payment> PaymentRepository::findById(int id) const
{
    QSqlQuery query(m_db);

    query.prepare(R"(
        SELECT id, order_session_id, method, amount, type, reverses_payment_id, created_at
        FROM payments
        WHERE id = :id
    )");

    query.bindValue(":id", id);

    if (!query.exec() || !query.next()) return std::nullopt;

    Payment payment;

    payment.id = query.value("id").toInt();
    payment.order_session_id = query.value("order_session_id").toInt();
    payment.method = query.value("method").toString();
    payment.amount = query.value("amount").toInt();
    payment.type = query.value("type").toString();
    payment.created_at = query.value("created_at").toString();

    if (!query.value("reverses_payment_id").isNull())
        payment.reverses_payment_id = query.value("reverses_payment_id").toInt();

    return payment;
}

QList<Payment> PaymentRepository::findByOrderSessionId(int orderSessionId) const
{
    QList<Payment> payments;

    QSqlQuery query(m_db);

    query.prepare(R"(
        SELECT
            id, order_session_id, method, amount, type, reverses_payment_id, created_at
        FROM payments
        WHERE order_session_id = :order_session_id
        ORDER BY id ASC
    )");

    query.bindValue(":order_session_id", orderSessionId);

    if (!query.exec()) return payments;

    while (query.next())
    {
        Payment payment;

        payment.id = query.value("id").toInt();
        payment.order_session_id = query.value("order_session_id").toInt();
        payment.method = query.value("method").toString();
        payment.amount = query.value("amount").toInt();
        payment.type = query.value("type").toString();
        payment.created_at = query.value("created_at").toString();

        if (!query.value("reverses_payment_id").isNull())
            payment.reverses_payment_id = query.value("reverses_payment_id").toInt();

        payments.append(payment);
    }

    return payments;
}

bool PaymentRepository::create(Payment& payment)
{
    QSqlQuery query(m_db);

    query.prepare(R"(
        INSERT INTO payments (order_session_id, method, amount, type, reverses_payment_id)
        VALUES (:order_session_id, :method, :amount, :type, :reverses_payment_id)
    )");

    query.bindValue(":order_session_id", payment.order_session_id);
    query.bindValue(":method", payment.method);
    query.bindValue(":amount", payment.amount);
    query.bindValue(":type", payment.type);

    if (payment.reverses_payment_id.has_value())
    {
        query.bindValue(":reverses_payment_id", *payment.reverses_payment_id);
    }
    else
    {
        query.bindValue(":reverses_payment_id", QVariant(QVariant::Int));
    }

    if (!query.exec()) return false;

    payment.id = query.lastInsertId().toInt();

    return true;
}
