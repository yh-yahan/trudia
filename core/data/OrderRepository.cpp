#include "OrderRepository.h"

#include <QSqlQuery>
#include <QSqlError>
#include <QVariant>
#include <QDebug>

OrderRepository::OrderRepository(QSqlDatabase db): m_db(db) {}

std::optional<Order> OrderRepository::getOrderById(int orderId)
{
    QSqlQuery query(m_db);
    query.prepare(R"(SELECT id, table_id, order_type, status, subtotal, tax, total, notes, closed_at
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
    order.table_id = query.value("table_id").toInt();
    order.order_type = query.value("order_type").toString();
    order.status = query.value("status").toString();
    order.subtotal = query.value("subtotal").toDouble();
    order.tax = query.value("tax").toDouble();
    order.total = query.value("total").toDouble();
    order.notes = query.value("notes").toString();
    order.closed_at = query.value("closed_at").toString();

    return order;
}

int OrderRepository::create(const Order &order)
{
    QSqlQuery query(m_db);
    query.prepare(R"(
        INSERT INTO orders (table_id, order_type, status, subtotal, tax, total, notes, closed_at)
        VALUES (:table_id, :order_type, :status, :subtotal, :tax, :total, :notes, :closed_at)
    )");

    if (order.table_id.has_value()) {
        query.bindValue(":table_id", order.table_id.value());
    } else {
        query.bindValue(":table_id", QVariant());
    }
    query.bindValue(":order_type", order.order_type);
    query.bindValue(":status", order.status);
    query.bindValue(":subtotal", order.subtotal);
    query.bindValue(":tax", order.tax);
    query.bindValue(":total", order.total);
    query.bindValue(":notes", order.notes);
    query.bindValue(":closed_at", order.closed_at);

    if (!query.exec()) {
        qWarning() << "create failed:" << query.lastError();

        return -1;
    }

    return query.lastInsertId().toInt();
}

void OrderRepository::update(const Order &order)
{
    QSqlQuery query(m_db);
    query.prepare(R"(
        UPDATE orders
        SET table_id = :table_id,
        order_type = :order_type,
        status = :status,
        subtotal = :subtotal,
        tax = :tax,
        total = :total,
        notes = :notes,
        closed_at = :closed_at
        WHERE id = :order_id
    )");

    query.bindValue(":order_id", order.id);
    if (order.table_id.has_value()) {
        query.bindValue(":table_id", order.table_id.value());
    } else {
        query.bindValue(":table_id", QVariant());
    }
    query.bindValue(":order_type", order.order_type);
    query.bindValue(":status", order.status);
    query.bindValue(":subtotal", order.subtotal);
    query.bindValue(":tax", order.tax);
    query.bindValue(":total", order.total);
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
