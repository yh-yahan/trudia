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
        closed_at = :closed_at,
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
