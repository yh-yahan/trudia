#include "OrderRepository.h"

#include <QSqlQuery>
#include <QSqlError>
#include <QVariant>
#include <QDebug>

OrderRepository::OrderRepository(QSqlDatabase db): m_db(db) {}

std::optional<Order> OrderRepository::getOrderById(int orderId)
{
    QSqlQuery query(m_db);
    query.prepare(R"(SELECT id, order_session_id, status, notes, closed_at
        FROM orders
        WHERE id = :id)");
    query.bindValue(":id", orderId);

    if (!query.exec()) {
        qWarning() << "getOrderById failed:" << query.lastError();
        return std::nullopt;
    }

    if (!query.next()) {
        return std::nullopt;
    }

    Order order;
    order.id = query.value("id").toInt();
    order.order_session_id = query.value("order_session_id").toInt();
    order.status = query.value("status").toString();
    order.notes = query.value("notes").toString();
    order.closed_at = query.value("closed_at").toString();

    return order;
}

std::vector<Order> OrderRepository::getOrdersByStatus(const QString &status)
{
    std::vector<Order> orders;

    QSqlQuery query(m_db);
    query.prepare(R"(
        SELECT id, display_number, order_session_id, status, notes, closed_at
        FROM orders
        WHERE status = :status
        ORDER BY created_at ASC
    )");

    query.bindValue(":status", status);

    if (!query.exec()) {
        qWarning() << "getOrdersByStatus failed:" << query.lastError();
        return orders;
    }

    while (query.next()) {
        Order order;
        order.id = query.value("id").toInt();
        order.display_number = query.value("display_number").toInt();
        order.order_session_id = query.value("order_session_id").toInt();
        order.status = query.value("status").toString();
        order.notes = query.value("notes").toString();
        order.closed_at = query.value("closed_at").toString();

        orders.push_back(order);
    }

    return orders;
}

std::vector<OpenOrderView> OrderRepository::getActiveOrderSessionOrders()
{
    std::vector<OpenOrderView> orders;

    QSqlQuery query(m_db);

    query.prepare(R"(
        SELECT 
            o.id AS order_id,
            o.display_number AS order_display_number,
            o.order_session_id,
            o.status AS order_status,
            o.notes AS order_notes,
            s.order_type AS session_order_type,
            s.table_id AS session_table_id
        FROM orders o
        JOIN order_sessions s ON o.order_session_id = s.id
        WHERE s.status != 'paid'
        ORDER BY o.created_at DESC
    )");

    if (!query.exec()) {
        qCritical() << "Failed to get active order session orders:" << query.lastError().text();
        return orders;
    }

    while (query.next()) {
        OpenOrderView order;

        order.id = query.value("order_id").toInt();
        order.display_number = query.value("order_display_number").toInt();
        order.order_session_id = query.value("order_session_id").toInt();
        order.status = query.value("order_status").toString();
        order.notes = query.value("order_notes").toString();

        order.order_type = query.value("session_order_type").toString();

        if (!query.value("session_table_id").isNull())
            order.table_id = query.value("session_table_id").toInt();
        else
            order.table_id = std::nullopt;

        orders.push_back(order);
    }

    return orders;
}

std::vector<Order> OrderRepository::getOrdersBySessionId(int orderSessionId)
{
    std::vector<Order> orders;

    QSqlQuery query(m_db);
    query.prepare(R"(SELECT id, display_number, order_session_id, status, notes, closed_at
                     FROM orders
                     WHERE order_session_id = :sessionId)");
    query.bindValue(":sessionId", orderSessionId);

    if (!query.exec()) {
        qWarning() << "Failed to get orders for session:" << query.lastError().text();
        return orders;
    }

    while (query.next()) {
        Order order;
        order.id = query.value("id").toInt();
        order.display_number = query.value("display_number").toInt();
        order.order_session_id = query.value("order_session_id").toInt();
        order.status = query.value("status").toString();
        order.notes = query.value("notes").toString();
        order.closed_at = query.value("closed_at").toString();
        orders.push_back(order);
    }

    return orders;
}

int OrderRepository::getMaxDisplayNumberForDate(const QString &date) {
    QSqlQuery query(m_db);

    query.prepare(
        "SELECT MAX(display_number) "
        "FROM orders "
        "WHERE DATE(created_at) = :date"
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

int OrderRepository::create(const Order &order)
{
    QSqlQuery query(m_db);
    query.prepare(R"(
        INSERT INTO orders
        (display_number, order_session_id, status, notes)
        VALUES (:display_number, :order_session_id, :status, :notes)
    )");

    query.bindValue(":display_number", order.display_number);
    query.bindValue(":order_session_id", order.order_session_id);
    query.bindValue(":status", order.status);
    query.bindValue(":notes", order.notes);

    if (!query.exec()) {
        qCritical() << "Failed to create order:" << query.lastError().text();
        return 0;
    }

    return query.lastInsertId().toInt();
}

void OrderRepository::update(const Order &order)
{
    QSqlQuery query(m_db);
    query.prepare(R"(
        UPDATE orders
        SET status = :status,
        notes = :notes,
        closed_at = :closed_at
        WHERE id = :order_id
    )");

    query.bindValue(":order_id", order.id);
    query.bindValue(":status", order.status);
    query.bindValue(":notes", order.notes);
    query.bindValue(":closed_at", order.closed_at);

    if (!query.exec()) {
        qWarning() << "update failed:" << query.lastError();
    }
}

void OrderRepository::remove(const Order &order)
{
    QSqlQuery query(m_db);
    query.prepare(R"(
        DELETE FROM orders
        WHERE id = :order_id
    )");

    query.bindValue(":order_id", order.id);

    if (!query.exec()) {
        qWarning() << "remove failed:" << query.lastError();
    }
}
