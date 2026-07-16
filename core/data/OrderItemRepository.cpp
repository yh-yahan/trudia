#include "OrderItemRepository.h"

#include <QSqlQuery>
#include <QSqlError>
#include <QVariant>
#include <QDebug>

OrderItemRepository::OrderItemRepository(QSqlDatabase db): m_db(db) {}

std::vector<OrderItem> OrderItemRepository::getAllOrderItems()
{
    std::vector<OrderItem> orderItems;

    QSqlQuery query(m_db);
    query.prepare(R"(SELECT id, 
        order_id, item_id, item_name, quantity, price, 
        is_taxable, item_status, notes 
        FROM order_items)");

    if (!query.exec()) {
        qWarning() << "getAllOrderItems failed:" << query.lastError();
        return orderItems;
    }

    while (query.next()) {
        OrderItem orderItem;
        orderItem.id = query.value("id").toInt();
        orderItem.order_id = query.value("order_id").toInt();
        orderItem.item_id = query.value("item_id").toInt();
        orderItem.item_name = query.value("item_name").toString();
        orderItem.quantity = query.value("quantity").toInt();
        orderItem.price = query.value("price").toDouble();
        orderItem.is_taxable = query.value("is_taxable").toBool();
        orderItem.item_status = query.value("item_status").toString();
        orderItem.notes = query.value("notes").toString();

        orderItems.push_back(orderItem);
    }

    return orderItems;
}

std::optional<OrderItem> OrderItemRepository::getOrderItemById(int orderItemId)
{
    QSqlQuery query(m_db);
    query.prepare(R"(SELECT id, order_id, item_id, item_name, quantity, price, is_taxable, item_status, notes
        FROM order_items
        WHERE id = :id)");
    query.bindValue(":id", orderItemId);

    if (!query.exec()) {
        qWarning() << "getOrderItemById failed:" << query.lastError();
        return std::nullopt;
    }

    if (!query.next()) {
        return std::nullopt;
    }

    OrderItem orderItem;
    orderItem.id = query.value("id").toInt();
    orderItem.order_id = query.value("order_id").toInt();
    orderItem.item_id = query.value("item_id").toInt();
    orderItem.item_name = query.value("item_name").toString();
    orderItem.quantity = query.value("quantity").toInt();
    orderItem.price = query.value("price").toDouble();
    orderItem.is_taxable = query.value("is_taxable").toBool();
    orderItem.item_status = query.value("item_status").toString();
    orderItem.notes = query.value("notes").toString();

    return orderItem;
}

std::vector<OrderItem> OrderItemRepository::getOrderItemsByOrderId(int orderId)
{
    std::vector<OrderItem> items;

    QSqlQuery query(m_db);
    query.prepare(R"(
        SELECT id, order_id, item_id, item_name, quantity, price, is_taxable, item_status, notes
        FROM order_items
        WHERE order_id = :order_id
    )");

    query.bindValue(":order_id", orderId);

    if (!query.exec()) {
        qWarning() << "getOrderItemsByOrderId failed:" << query.lastError();
        return items;
    }

    while (query.next()) {
        OrderItem item;
        item.id = query.value("id").toInt();
        item.order_id = query.value("order_id").toInt();
        item.item_id = query.value("item_id").toInt();
        item.item_name = query.value("item_name").toString();
        item.quantity = query.value("quantity").toInt();
        item.price = query.value("price").toDouble();
        item.is_taxable = query.value("is_taxable").toBool();
        item.item_status = query.value("item_status").toString();
        item.notes = query.value("notes").toString();

        items.push_back(item);
    }

    return items;
}

std::vector<OrderItem> OrderItemRepository::getOrderItemsByOrderIds(const QList<int> &orderIds)
{
    std::vector<OrderItem> items;

    if (orderIds.isEmpty()) return items;

    QStringList placeholders;
    for (int i = 0; i < orderIds.size(); ++i)
        placeholders << "?";

    QString sql = QString(
                      "SELECT id, order_id, item_id, item_name, quantity, price, is_taxable, item_status, notes "
                      "FROM order_items "
                      "WHERE order_id IN (%1)"
                      ).arg(placeholders.join(","));

    QSqlQuery query(m_db);
    query.prepare(sql);

    for (int i = 0; i < orderIds.size(); ++i)
        query.addBindValue(orderIds[i]);

    if (!query.exec()) {
        qWarning() << "getOrderItemsByOrderIds failed:" << query.lastError();
        return items;
    }

    while (query.next()) {
        OrderItem item;
        item.id = query.value("id").toInt();
        item.order_id = query.value("order_id").toInt();
        item.item_id = query.value("item_id").toInt();
        item.item_name = query.value("item_name").toString();
        item.quantity = query.value("quantity").toInt();
        item.price = query.value("price").toDouble();
        item.is_taxable = query.value("is_taxable").toBool();
        item.item_status = query.value("item_status").toString();
        item.notes = query.value("notes").toString();

        items.push_back(item);
    }

    return items;
}

bool OrderItemRepository::markItemsByOrderId(int orderId, const QString &status)
{
    QSqlQuery query(m_db);
    query.prepare(R"(
        UPDATE order_items
        SET item_status = :status
        WHERE order_id = :order_id
    )");

    query.bindValue(":status", status);
    query.bindValue(":order_id", orderId);

    if (!query.exec()) {
        qWarning() << "markItemsByOrderId failed:" << query.lastError();
        return false;
    }

    return true;
}

void OrderItemRepository::create(OrderItem &orderItem)
{
    QSqlQuery query(m_db);
    query.prepare(R"(
        INSERT INTO order_items (order_id, item_id, item_name, quantity, price, is_taxable, item_status, notes)
        VALUES (:order_id, :item_id, :item_name, :quantity, :price, :is_taxable, :item_status, :notes)
    )");

    query.bindValue(":order_id", orderItem.order_id);
    query.bindValue(":item_id", orderItem.item_id);
    query.bindValue(":item_name", orderItem.item_name);
    query.bindValue(":quantity", orderItem.quantity);
    query.bindValue(":price", orderItem.price);
    query.bindValue(":is_taxable", orderItem.is_taxable);
    query.bindValue(":item_status", orderItem.item_status);
    query.bindValue(":notes", orderItem.notes);

    if (!query.exec()) {
        qWarning() << "[OrderItemRepository] create failed:" << query.lastError();
    }

    orderItem.id = query.lastInsertId().toInt();
}

void OrderItemRepository::update(const OrderItem &orderItem){
    QSqlQuery query(m_db);
    query.prepare(R"(
        UPDATE order_items
        SET item_id = :item_id,
        item_name = :item_name,
        quantity = :quantity,
        price = :price,
        is_taxable = :is_taxable,
        item_status = :item_status,
        notes = :notes
        WHERE id = :order_item_id
    )");

    query.bindValue(":order_item_id", orderItem.id);
    query.bindValue(":item_id", orderItem.item_id);
    query.bindValue(":item_name", orderItem.item_name);
    query.bindValue(":quantity", orderItem.quantity);
    query.bindValue(":price", orderItem.price);
    query.bindValue(":is_taxable", orderItem.is_taxable);
    query.bindValue(":item_status", orderItem.item_status);
    query.bindValue(":notes", orderItem.notes);

    if (!query.exec()) {
        qWarning() << "update failed:" << query.lastError();
    }
}

void OrderItemRepository::remove(const OrderItem &orderItem)
{
    QSqlQuery query(m_db);
    query.prepare(R"(
        DELETE FROM order_items
        WHERE id = :order_item_id
    )");

    query.bindValue(":order_item_id", orderItem.id);

    if (!query.exec()) {
        qWarning() << "remove failed:" << query.lastError();
    }
}

void OrderItemRepository::removeByOrderId(int orderId)
{
    QSqlQuery query(m_db);
    query.prepare("DELETE FROM order_items WHERE order_id = ?");
    query.addBindValue(orderId);

    if (!query.exec())
    {
        qCritical() << "Failed to remove order items:" << query.lastError();
    }
}
