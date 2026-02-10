#include "OrderSessionRepository.h"

#include <QSqlQuery>
#include <QSqlError>
#include <QVariant>
#include <QDebug>

OrderSessionRepository::OrderSessionRepository(QSqlDatabase db): m_db(db) {}

std::vector<OrderSession> OrderSessionRepository::getAllActiveOrderSessions()
{
    std::vector<OrderSession> orderSessions;

    QSqlQuery query(m_db);
    query.prepare(R"(SELECT * FROM order_sessions WHERE status = 'open')");

    if (!query.exec()) {
        qWarning() << "Failed to get active order sessions:" << query.lastError().text();
        return orderSessions;
    }

    while (query.next()) {
        OrderSession orderSession;
        orderSession.id = query.value("id").toInt();
        orderSession.display_number = query.value("display_number").toInt();
        orderSession.table_id = query.value("table_id").isNull() ? std::nullopt : std::make_optional(query.value("table_id").toInt());
        orderSession.order_type = query.value("order_type").toString();
        orderSession.status = query.value("status").toString();
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

    if (!query.exec()) {
        qWarning() << "Failed to get order session by id:" << query.lastError().text();
        return std::nullopt;
    }

    if (query.next()) {
        OrderSession session;
        session.id = query.value("id").toInt();
        session.display_number = query.value("display_number").toInt();
        session.table_id = query.value("table_id").isNull() ? std::nullopt : std::make_optional(query.value("table_id").toInt());
        session.order_type = query.value("order_type").toString();
        session.status = query.value("status").toString();
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

std::optional<OrderSession>
OrderSessionRepository::getByOrderId(int orderId)
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

    if (!query.exec()) {
        qWarning() << "Failed to get order session by order id:"
                   << query.lastError().text();
        return std::nullopt;
    }

    if (!query.next()) return std::nullopt;

    OrderSession session;
    session.id = query.value("id").toInt();
    session.display_number = query.value("display_number").toInt();
    session.table_id = query.value("table_id").isNull()
                           ? std::nullopt
                           : std::make_optional(query.value("table_id").toInt());
    session.order_type = query.value("order_type").toString();
    session.status = query.value("status").toString();
    session.subtotal = query.value("subtotal").toDouble();
    session.tax = query.value("tax").toDouble();
    session.discount = query.value("discount").toDouble();
    session.total = query.value("total").toDouble();
    session.opened_at = query.value("opened_at").toString();
    session.closed_at = query.value("closed_at").toString();

    return session;
}

int OrderSessionRepository::getMaxDisplayNumberForDate(const QString &date) {
    QSqlQuery query(m_db);

    query.prepare(
        "SELECT MAX(display_number) "
        "FROM order_sessions "
        "WHERE DATE(opened_at) = :date"
        );
    query.bindValue(":date", date);

    if (!query.exec()) {
        qWarning() << "Failed to get max display number:" << query.lastError();
        return 0;
    }

    if (query.next()) {
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

    if (query.exec() && query.next()) {
        return query.value("id").toInt();
    }

    return 0;
}

int OrderSessionRepository::create(const OrderSession &orderSession)
{
    QSqlQuery query(m_db);
    query.prepare(R"(INSERT INTO order_sessions
                     (display_number, table_id, order_type, status, subtotal, tax, discount, total, closed_at)
                     VALUES (:display_number, :table_id, :order_type, :status, :subtotal, :tax, :discount, :total, :closed_at))");

    query.bindValue(":display_number", orderSession.display_number);
    if (orderSession.table_id.has_value()) {
        query.bindValue(":table_id", orderSession.table_id.value());
    } else {
        query.bindValue(":table_id", QVariant());
    }
    query.bindValue(":order_type", orderSession.order_type);
    query.bindValue(":status", orderSession.status);
    query.bindValue(":subtotal", orderSession.subtotal);
    query.bindValue(":tax", orderSession.tax);
    query.bindValue(":discount", orderSession.discount);
    query.bindValue(":total", orderSession.total);
    if (orderSession.closed_at.has_value()) {
        query.bindValue(":closed_at", orderSession.closed_at.value());
    } else {
        query.bindValue(":closed_at", QVariant());
    }

    if (!query.exec()) {
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
                     table_id = :table_id,
                     order_type = :order_type,
                     status = :status,
                     subtotal = :subtotal,
                     tax = :tax,
                     discount = :discount,
                     total = :total,
                     closed_at = :closed_at
                     WHERE id = :id)");

    query.bindValue(":display_number", orderSession.display_number);
    if (orderSession.table_id.has_value()) {
        query.bindValue(":table_id", orderSession.table_id.value());
    } else {
        query.bindValue(":table_id", QVariant());
    }
    query.bindValue(":order_type", orderSession.order_type);
    query.bindValue(":status", orderSession.status);
    query.bindValue(":subtotal", orderSession.subtotal);
    query.bindValue(":tax", orderSession.tax);
    query.bindValue(":discount", orderSession.discount);
    query.bindValue(":total", orderSession.total);
    if (orderSession.closed_at.has_value()) {
        query.bindValue(":closed_at", orderSession.closed_at.value());
    } else {
        query.bindValue(":closed_at", QVariant());
    }
    query.bindValue(":id", orderSession.id);

    if (!query.exec()) {
        qWarning() << "Failed to update order session:" << query.lastError().text();
    }
}
