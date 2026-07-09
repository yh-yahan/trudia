#include "ReceiptSnapshotRepository.h"

#include <QSqlQuery>
#include <QSqlError>
#include <QVariant>
#include <optional>

ReceiptSnapshotRepository::ReceiptSnapshotRepository(QSqlDatabase db)
    : m_db(db) {}

int ReceiptSnapshotRepository::create(const ReceiptSnapshot &snapshot)
{
    QSqlQuery query(m_db);

    query.prepare(R"(
        INSERT INTO receipt_snapshot (
            order_session_id, cashier_name, store_name, address, phone,
            email, website, tax_name, tax_rate, tax_registration_number,
            member_phone, points_balance_before, points_balance_after,
            order_type, table_name
        )
        VALUES (
            :order_session_id, :cashier_name, :store_name, :address, :phone,
            :email, :website, :tax_name, :tax_rate, :tax_registration_number,
            :member_phone, :points_balance_before, :points_balance_after,
            :order_type, :table_name
        )
    )");

    query.bindValue(":order_session_id", snapshot.order_session_id);
    query.bindValue(":cashier_name", snapshot.cashier_name ? *snapshot.cashier_name : QVariant());
    query.bindValue(":store_name", snapshot.store_name ? *snapshot.store_name : QVariant());
    query.bindValue(":address", snapshot.address ? *snapshot.address : QVariant());
    query.bindValue(":phone", snapshot.phone ? *snapshot.phone : QVariant());
    query.bindValue(":email", snapshot.email ? *snapshot.email : QVariant());
    query.bindValue(":website", snapshot.website ? *snapshot.website : QVariant());
    query.bindValue(":tax_name", snapshot.tax_name ? *snapshot.tax_name : QVariant());
    query.bindValue(":tax_rate", snapshot.tax_rate ? *snapshot.tax_rate : QVariant());
    query.bindValue(":tax_registration_number", snapshot.tax_registration_number ? *snapshot.tax_registration_number : QVariant());
    query.bindValue(":member_phone", snapshot.member_phone ? *snapshot.member_phone : QVariant());
    query.bindValue(":points_balance_before", snapshot.points_balance_before ? *snapshot.points_balance_before : QVariant());
    query.bindValue(":points_balance_after", snapshot.points_balance_after ? *snapshot.points_balance_after : QVariant());
    query.bindValue(":order_type", snapshot.order_type ? *snapshot.order_type : QVariant());
    query.bindValue(":table_name", snapshot.table_name ? *snapshot.table_name : QVariant());

    if (!query.exec())
        return -1;

    return query.lastInsertId().toInt();
}

std::optional<ReceiptSnapshot> ReceiptSnapshotRepository::getByOrderSessionId(int orderSessionId)
{
    QSqlQuery query(m_db);

    query.prepare(R"(
        SELECT
            id, order_session_id, cashier_name, store_name, address, phone,
            email, website, tax_name, tax_rate, tax_registration_number,
            member_phone, points_balance_before, points_balance_after,
            order_type, table_name, created_at
        FROM receipt_snapshot
        WHERE order_session_id = :order_session_id
        LIMIT 1
    )");

    query.bindValue(":order_session_id", orderSessionId);

    if (!query.exec())
        return std::nullopt;

    if (!query.next())
        return std::nullopt;

    ReceiptSnapshot snapshot;

    snapshot.id = query.value("id").toInt();
    snapshot.order_session_id = query.value("order_session_id").toInt();

    if (!query.value("cashier_name").isNull())
        snapshot.cashier_name = query.value("cashier_name").toString();

    if (!query.value("store_name").isNull())
        snapshot.store_name = query.value("store_name").toString();

    if (!query.value("address").isNull())
        snapshot.address = query.value("address").toString();

    if (!query.value("phone").isNull())
        snapshot.phone = query.value("phone").toString();

    if (!query.value("email").isNull())
        snapshot.email = query.value("email").toString();

    if (!query.value("website").isNull())
        snapshot.website = query.value("website").toString();

    if (!query.value("tax_name").isNull())
        snapshot.tax_name = query.value("tax_name").toString();

    if (!query.value("tax_rate").isNull())
        snapshot.tax_rate = query.value("tax_rate").toInt();

    if (!query.value("tax_registration_number").isNull())
        snapshot.tax_registration_number = query.value("tax_registration_number").toString();

    if (!query.value("member_phone").isNull())
        snapshot.member_phone = query.value("member_phone").toString();

    if (!query.value("points_balance_before").isNull())
        snapshot.points_balance_before = query.value("points_balance_before").toInt();

    if (!query.value("points_balance_after").isNull())
        snapshot.points_balance_after = query.value("points_balance_after").toInt();

    if (!query.value("order_type").isNull())
        snapshot.order_type = query.value("order_type").toString();

    if (!query.value("table_name").isNull())
        snapshot.table_name = query.value("table_name").toString();

    snapshot.created_at = query.value("created_at").toString();

    return snapshot;
}
