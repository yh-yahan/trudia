#include "MembershipTransactionRepository.h"

#include <QSqlQuery>
#include <QSqlError>
#include <QVariant>
#include "../logging/LoggingCategories.h"

MembershipTransactionRepository::MembershipTransactionRepository(QSqlDatabase db): m_db(db) {}

std::vector<TransactionRow> MembershipTransactionRepository::getTransactionRowsByMembershipId(int membershipId)
{
    std::vector<TransactionRow> rows;

    if (membershipId <= 0) {
        qCWarning(logMembership) << "Invalid membership ID:" << membershipId;
        return rows;
    }

    QSqlQuery query(m_db);
    query.prepare(R"(
        SELECT
            mt.id,
            mt.membership_id,
            mt.order_session_id,
            mt.type,
            mt.points,
            mt.created_at,
            os.display_number
        FROM membership_transactions mt
        LEFT JOIN order_sessions os
            ON mt.order_session_id = os.id
        WHERE mt.membership_id = :membership_id
        ORDER BY mt.created_at DESC
    )");

    query.bindValue(":membership_id", membershipId);

    if (!query.exec()) {
        qCWarning(logDatabase)
            << "Failed to fetch membership transaction history:"
            << query.lastError().text();
        return rows;
    }

    while (query.next()) {
        TransactionRow row;

        row.transaction.id = query.value("id").toInt();
        row.transaction.membership_id = query.value("membership_id").toInt();
        row.transaction.order_session_id = query.value("order_session_id").toInt();
        row.transaction.type = query.value("type").toString();
        row.transaction.points = query.value("points").toInt();

        row.created_at = query.value("created_at").toDateTime();
        row.created_at.setTimeSpec(Qt::UTC);
        row.orderDisplayNumber = query.value("display_number").toInt();

        rows.push_back(std::move(row));
    }

    return rows;
}

bool MembershipTransactionRepository::create(const MembershipTransaction &transaction)
{
    if (transaction.membership_id <= 0) {
        qCWarning(logMembership) << "Invalid membership ID:" << transaction.membership_id;
        return false;
    }

    if (transaction.points <= 0) {
        qCWarning(logMembership) << "Points must be greater than zero.";
        return false;
    }

    if (transaction.type != "earn" && transaction.type != "redeem") {
        qCWarning(logMembership) << "Invalid transaction type:" << transaction.type;
        return false;
    }

    QSqlQuery query(m_db);

    query.prepare(R"(
        INSERT INTO membership_transactions
        (membership_id, order_session_id, type, points)
        VALUES (:membership_id, :order_session_id, :type, :points)
    )");

    query.bindValue(":membership_id", transaction.membership_id);
    query.bindValue(":order_session_id", transaction.order_session_id);
    query.bindValue(":type", transaction.type);
    query.bindValue(":points", transaction.points);

    if (!query.exec()) {
        qCWarning(logDatabase) << "Failed to insert membership transaction:"
                 << query.lastError().text();
        return false;
    }

    return true;
}

MembershipTransaction MembershipTransactionRepository::getById(int id)
{
    MembershipTransaction transaction;

    if (id <= 0) {
        qCWarning(logMembership) << "Invalid transaction ID:" << id;
        return transaction;
    }

    QSqlQuery query(m_db);
    query.prepare(R"(
        SELECT id, membership_id, order_session_id, type, points
        FROM membership_transactions
        WHERE id = :id
    )");

    query.bindValue(":id", id);

    if (!query.exec()) {
        qCWarning(logDatabase) << "Failed to fetch membership transaction:"
                 << query.lastError().text();
        return transaction;
    }

    if (query.next()) {
        transaction.id = query.value("id").toInt();
        transaction.membership_id = query.value("membership_id").toInt();
        transaction.order_session_id = query.value("order_session_id").toInt();
        transaction.type = query.value("type").toString();
        transaction.points = query.value("points").toInt();
    } else {
        qCWarning(logMembership) << "No membership transaction found with ID:" << id;
    }

    return transaction;
}

std::vector<MembershipTransaction> MembershipTransactionRepository::getByMembershipId(int membershipId)
{
    std::vector<MembershipTransaction> transactions;

    if (membershipId <= 0) {
        qCWarning(logMembership) << "Invalid membership ID:" << membershipId;
        return transactions;
    }

    QSqlQuery query(m_db);
    query.prepare(R"(
        SELECT id, membership_id, order_session_id, type, points
        FROM membership_transactions
        WHERE membership_id = :membership_id
        ORDER BY created_at DESC
    )");

    query.bindValue(":membership_id", membershipId);

    if (!query.exec()) {
        qCWarning(logDatabase) << "Failed to fetch transactions for membership:"
                 << query.lastError().text();
        return transactions;
    }

    while (query.next()) {
        MembershipTransaction transaction;
        transaction.id = query.value("id").toInt();
        transaction.membership_id = query.value("membership_id").toInt();
        transaction.order_session_id = query.value("order_session_id").toInt();
        transaction.type = query.value("type").toString();
        transaction.points = query.value("points").toInt();

        transactions.push_back(transaction);
    }

    return transactions;
}

std::vector<MembershipTransaction> MembershipTransactionRepository::getByOrderSessionId(int orderSessionId)
{
    std::vector<MembershipTransaction> transactions;

    if (orderSessionId <= 0) {
        qCWarning(logMembership) << "Invalid order session ID:" << orderSessionId;
        return transactions;
    }

    QSqlQuery query(m_db);
    query.prepare(R"(
        SELECT id, membership_id, order_session_id, type, points
        FROM membership_transactions
        WHERE order_session_id = :order_session_id
        ORDER BY created_at DESC
    )");

    query.bindValue(":order_session_id", orderSessionId);

    if (!query.exec()) {
        qCWarning(logDatabase) << "Failed to fetch transactions for order session:"
                 << query.lastError().text();
        return transactions;
    }

    while (query.next()) {
        MembershipTransaction transaction;
        transaction.id = query.value("id").toInt();
        transaction.membership_id = query.value("membership_id").toInt();
        transaction.order_session_id = query.value("order_session_id").toInt();
        transaction.type = query.value("type").toString();
        transaction.points = query.value("points").toInt();

        transactions.push_back(transaction);
    }

    return transactions;
}

std::vector<MembershipTransaction> MembershipTransactionRepository::getByType(const QString &type)
{
    std::vector<MembershipTransaction> transactions;

    if (type != "earn" && type != "redeem") {
        qCWarning(logMembership) << "Invalid transaction type:" << type;
        return transactions;
    }

    QSqlQuery query(m_db);
    query.prepare(R"(
        SELECT id, membership_id, order_session_id, type, points
        FROM membership_transactions
        WHERE type = :type
        ORDER BY created_at DESC
    )");

    query.bindValue(":type", type);

    if (!query.exec()) {
        qCWarning(logDatabase) << "Failed to fetch transactions by type:"
                 << query.lastError().text();
        return transactions;
    }

    while (query.next()) {
        MembershipTransaction transaction;
        transaction.id = query.value("id").toInt();
        transaction.membership_id = query.value("membership_id").toInt();
        transaction.order_session_id = query.value("order_session_id").toInt();
        transaction.type = query.value("type").toString();
        transaction.points = query.value("points").toInt();

        transactions.push_back(transaction);
    }

    return transactions;
}

int MembershipTransactionRepository::getPointsByType(int orderSessionId, const QString &type)
{
    if (orderSessionId <= 0)
        return 0;

    QSqlQuery query(m_db);
    query.prepare(R"(
        SELECT COALESCE(SUM(points), 0)
        FROM membership_transactions
        WHERE order_session_id = :order_session_id
          AND type = :type
    )");

    query.bindValue(":order_session_id", orderSessionId);
    query.bindValue(":type", type);

    if (!query.exec() || !query.next()) {
        qCWarning(logDatabase) << "Failed to sum points:" << query.lastError().text();
        return 0;
    }

    return query.value(0).toInt();
}

int MembershipTransactionRepository::getMembershipIdBySession(int orderSessionId)
{
    QSqlQuery query(m_db);
    query.prepare(R"(
        SELECT membership_id
        FROM membership_transactions
        WHERE order_session_id = :order_session_id
        LIMIT 1
    )");

    query.bindValue(":order_session_id", orderSessionId);

    if (!query.exec() || !query.next())
        return 0;

    return query.value(0).toInt();
}

int MembershipTransactionRepository::getRedeemedPoints(int orderSessionId)
{
    return getPointsByType(orderSessionId, "redeem");
}

int MembershipTransactionRepository::getEarnedPoints(int orderSessionId)
{
    return getPointsByType(orderSessionId, "earn");
}
