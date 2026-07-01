#include "OrderSessionRepository.h"

#include <QSqlQuery>
#include <QSqlError>
#include <QVariant>
#include <QDebug>

OrderSessionRepository::OrderSessionRepository(QSqlDatabase db) : m_db(db) {}

std::vector<OrderSession> OrderSessionRepository::getAllActiveOrderSessions()
{
    std::vector<OrderSession> orderSessions;

    QSqlQuery query(m_db);
    query.prepare(R"(SELECT * FROM order_sessions WHERE status = 'open')");

    if (!query.exec())
    {
        qWarning() << "Failed to get active order sessions:" << query.lastError().text();
        return orderSessions;
    }

    while (query.next())
    {
        OrderSession orderSession;
        orderSession.id = query.value("id").toInt();
        orderSession.display_number = query.value("display_number").toInt();
        orderSession.receipt_number = query.value("receipt_number").isNull() ? 
                                    std::nullopt
                                    : std::make_optional(query.value("receipt_number").toString());
        orderSession.table_id = query.value("table_id").isNull() ? std::nullopt : std::make_optional(query.value("table_id").toInt());
        orderSession.order_type = query.value("order_type").toString();
        orderSession.status = query.value("status").toString();
        orderSession.points_earned = query.value("points_earned").toInt();
        orderSession.points_redeemed = query.value("points_redeemed").toInt();
        orderSession.subtotal = query.value("subtotal").toDouble();
        orderSession.tax = query.value("tax").toDouble();
        orderSession.discount = query.value("discount").toDouble();
        orderSession.total = query.value("total").toDouble();
        orderSession.opened_at = query.value("opened_at").toString();
        orderSession.closed_at = query.value("closed_at").toString();

        orderSessions.push_back(orderSession);
    }

    return orderSessions;
}

std::optional<OrderSession> OrderSessionRepository::getById(const int &orderSessionId)
{
    QSqlQuery query(m_db);
    query.prepare(R"(SELECT * FROM order_sessions WHERE id = :id)");
    query.bindValue(":id", orderSessionId);

    if (!query.exec())
    {
        qWarning() << "Failed to get order session by id:" << query.lastError().text();
        return std::nullopt;
    }

    if (query.next())
    {
        OrderSession session;
        session.id = query.value("id").toInt();
        session.display_number = query.value("display_number").toInt();
        session.receipt_number = query.value("receipt_number").isNull() ? 
                                    std::nullopt
                                    : std::make_optional(query.value("receipt_number").toString());
        session.table_id = query.value("table_id").isNull() ? std::nullopt : std::make_optional(query.value("table_id").toInt());
        session.order_type = query.value("order_type").toString();
        session.status = query.value("status").toString();
        session.points_earned = query.value("points_earned").toInt();
        session.points_redeemed = query.value("points_redeemed").toInt();
        session.subtotal = query.value("subtotal").toDouble();
        session.tax = query.value("tax").toDouble();
        session.discount = query.value("discount").toDouble();
        session.total = query.value("total").toDouble();
        session.opened_at = query.value("opened_at").toString();
        session.closed_at = query.value("closed_at").toString();
        return session;
    }

    return std::nullopt;
}

std::optional<OrderSession> OrderSessionRepository::getByOrderId(int orderId)
{
    QSqlQuery query(m_db);
    query.prepare(R"(
        SELECT os.*
        FROM order_sessions os
        JOIN orders o ON o.order_session_id = os.id
        WHERE o.id = :orderId
        LIMIT 1
    )");
    query.bindValue(":orderId", orderId);

    if (!query.exec())
    {
        qWarning() << "Failed to get order session by order id:"
                   << query.lastError().text();
        return std::nullopt;
    }

    if (!query.next())
        return std::nullopt;

    OrderSession session;
    session.id = query.value("id").toInt();
    session.display_number = query.value("display_number").toInt();
    session.receipt_number = query.value("receipt_number").isNull() ? 
                                std::nullopt
                                : std::make_optional(query.value("receipt_number").toString());
    session.table_id = query.value("table_id").isNull()
                           ? std::nullopt
                           : std::make_optional(query.value("table_id").toInt());
    session.order_type = query.value("order_type").toString();
    session.status = query.value("status").toString();
    session.points_earned = query.value("points_earned").toInt();
    session.points_redeemed = query.value("points_redeemed").toInt();
    session.subtotal = query.value("subtotal").toDouble();
    session.tax = query.value("tax").toDouble();
    session.discount = query.value("discount").toDouble();
    session.total = query.value("total").toDouble();
    session.opened_at = query.value("opened_at").toString();
    session.closed_at = query.value("closed_at").toString();

    return session;
}

int OrderSessionRepository::getMaxDisplayNumberForDate(const QString &date)
{
    QSqlQuery query(m_db);

    query.prepare(
        "SELECT MAX(display_number) "
        "FROM order_sessions "
        "WHERE DATE(opened_at) = :date");
    query.bindValue(":date", date);

    if (!query.exec())
    {
        qWarning() << "Failed to get max display number:" << query.lastError();
        return 0;
    }

    if (query.next())
    {
        return query.value(0).toInt();
    }

    return 0;
}

int OrderSessionRepository::findOpenSessionByTableId(int const &tableId)
{
    QSqlQuery query(m_db);

    query.prepare(R"(SELECT id
                     FROM order_sessions
                     WHERE table_id = :tableId
                     AND status = 'open'
                     AND order_type = 'dine_in'
                     LIMIT 1)");
    query.bindValue(":tableId", tableId);

    if (query.exec() && query.next())
    {
        return query.value("id").toInt();
    }

    return 0;
}

int OrderSessionRepository::create(const OrderSession &orderSession)
{
    QSqlQuery query(m_db);
    query.prepare(R"(INSERT INTO order_sessions
                     (display_number, receipt_number, table_id, order_type, status, points_earned, points_redeemed, subtotal, tax, discount, total, closed_at)
                     VALUES (:display_number, NULL, :table_id, :order_type, :status, :points_earned, :points_redeemed, :subtotal, :tax, :discount, :total, NULL))");

    query.bindValue(":display_number", orderSession.display_number);
    if (orderSession.table_id.has_value())
    {
        query.bindValue(":table_id", orderSession.table_id.value());
    }
    else
    {
        query.bindValue(":table_id", QVariant());
    }
    query.bindValue(":order_type", orderSession.order_type);
    query.bindValue(":status", orderSession.status);
    query.bindValue(":points_earned", orderSession.points_earned);
    query.bindValue(":points_redeemed", orderSession.points_redeemed);
    query.bindValue(":subtotal", orderSession.subtotal);
    query.bindValue(":tax", orderSession.tax);
    query.bindValue(":discount", orderSession.discount);
    query.bindValue(":total", orderSession.total);

    if (!query.exec())
    {
        qWarning() << "Failed to create order session:" << query.lastError().text();
        return 0;
    }

    return query.lastInsertId().toInt();
}

void OrderSessionRepository::update(const OrderSession &orderSession)
{
    QSqlQuery query(m_db);
    query.prepare(R"(UPDATE order_sessions SET
                     display_number = :display_number,
                     receipt_number = :receipt_number,
                     table_id = :table_id,
                     order_type = :order_type,
                     status = :status,
                     points_earned = :points_earned,
                     points_redeemed = :points_redeemed,
                     subtotal = :subtotal,
                     tax = :tax,
                     discount = :discount,
                     total = :total
                     WHERE id = :id)");

    query.bindValue(":display_number", orderSession.display_number);
    
    if (orderSession.receipt_number.has_value()) {
        query.bindValue(":receipt_number", orderSession.receipt_number.value());
    } else {
        query.bindValue(":receipt_number", QVariant());
    }

    if (orderSession.table_id.has_value()) {
        query.bindValue(":table_id", orderSession.table_id.value());
    } else {
        query.bindValue(":table_id", QVariant());
    }
    query.bindValue(":order_type", orderSession.order_type);
    query.bindValue(":status", orderSession.status);
    query.bindValue(":points_earned", orderSession.points_earned);
    query.bindValue(":points_redeemed", orderSession.points_redeemed);
    query.bindValue(":subtotal", orderSession.subtotal);
    query.bindValue(":tax", orderSession.tax);
    query.bindValue(":discount", orderSession.discount);
    query.bindValue(":total", orderSession.total);
    query.bindValue(":id", orderSession.id);

    if (!query.exec()) {
        qWarning() << "Failed to update order session:" << query.lastError().text();
    }
}

void OrderSessionRepository::markAsPaid(int orderId)
{
    QSqlQuery query(m_db);
    query.prepare(R"(UPDATE order_sessions
                     SET status = 'paid',
                         closed_at = CURRENT_TIMESTAMP
                     WHERE id = :id)");
    query.bindValue(":id", orderId);

    if (!query.exec())
    {
        qWarning() << "Failed to mark order as closed:" << query.lastError().text();
    }
}

std::vector<OrderSession> OrderSessionRepository::getRecentPaidSessions(int limit)
{
    std::vector<OrderSession> orderSessions;

    QSqlQuery query(m_db);
    query.prepare(R"(
        SELECT *
        FROM order_sessions
        WHERE status = 'paid'
        ORDER BY closed_at DESC
        LIMIT :limit
    )");

    query.bindValue(":limit", limit);

    if (!query.exec())
    {
        qWarning() << "Failed to get recent paid sessions:"
                   << query.lastError().text();
        return orderSessions;
    }

    while (query.next())
    {
        OrderSession orderSession;

        orderSession.id = query.value("id").toInt();
        orderSession.display_number = query.value("display_number").toInt();
        orderSession.receipt_number = query.value("receipt_number").isNull() ? 
                                    std::nullopt
                                    : std::make_optional(query.value("receipt_number").toString());
        orderSession.table_id = query.value("table_id").isNull()
                                    ? std::nullopt
                                    : std::make_optional(query.value("table_id").toInt());
        orderSession.order_type = query.value("order_type").toString();
        orderSession.status = query.value("status").toString();
        orderSession.points_earned = query.value("points_earned").toInt();
        orderSession.points_redeemed = query.value("points_redeemed").toInt();
        orderSession.subtotal = query.value("subtotal").toDouble();
        orderSession.tax = query.value("tax").toDouble();
        orderSession.discount = query.value("discount").toDouble();
        orderSession.total = query.value("total").toDouble();
        orderSession.opened_at = query.value("opened_at").toString();
        orderSession.closed_at = query.value("closed_at").toString();

        orderSessions.push_back(orderSession);
    }

    return orderSessions;
}
