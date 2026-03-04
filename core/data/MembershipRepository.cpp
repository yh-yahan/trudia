#include "MembershipRepository.h"

#include <QSqlQuery>
#include <QSqlError>
#include <QVariant>
#include <QDebug>

MembershipRepository::MembershipRepository(QSqlDatabase db): m_db(db) {}

Membership MembershipRepository::getMembershipById(const int &id)
{
    Membership membership;

    QSqlQuery query(m_db);
    query.prepare(R"(
        SELECT id, phone_number, total_points, status
        FROM memberships
        WHERE id = :id
    )");

    query.bindValue(":id", id);

    if (!query.exec()) {
        qDebug() << "Failed to fetch membership:" << query.lastError().text();
        return membership;
    }

    if (query.next()) {
        membership.id = query.value("id").toInt();
        membership.phone_number = query.value("phone_number").toString();
        membership.total_points = query.value("total_points").toInt();
        membership.status = query.value("status").toString();
    } else {
        qDebug() << "No membership found with ID:" << id;
    }

    return membership;
}

Membership MembershipRepository::getMembershipByPhoneNumber(const QString &phoneNumber)
{
    Membership membership;

    QSqlQuery query(m_db);
    query.prepare(R"(
        SELECT id, phone_number, total_points, status
        FROM memberships
        WHERE phone_number = :phone_number
    )");

    query.bindValue(":phone_number", phoneNumber);

    if (!query.exec()) {
        qDebug() << "Failed to fetch membership:" << query.lastError().text();

        return membership;
    }

    if (query.next()) {
        membership.id = query.value("id").toInt();
        membership.phone_number = query.value("phone_number").toString();
        membership.total_points = query.value("total_points").toInt();
        membership.status = query.value("status").toString();
    } else {
        qDebug() << "No membership found with phone number:" << phoneNumber;
    }

    return membership;
}

QList<Membership> MembershipRepository::getAllMemberships()
{
    QList<Membership> memberships;

    QSqlQuery query(m_db);
    if (!query.exec("SELECT id, phone_number, total_points, status FROM memberships")) {
        qDebug() << "Failed to fetch all memberships:" << query.lastError().text();
        return memberships;
    }

    while (query.next()) {
        Membership membership;
        membership.id = query.value("id").toInt();
        membership.phone_number = query.value("phone_number").toString();
        membership.total_points = query.value("total_points").toInt();
        membership.status = query.value("status").toString();
        memberships.append(membership);
    }

    return memberships;
}

bool MembershipRepository::create(const Membership &membership)
{
    QSqlQuery query(m_db);
    query.prepare(R"(
        INSERT INTO memberships (phone_number, total_points, status)
        VALUES (:phone_number, :total_points, :status)
    )");

    query.bindValue(":phone_number", membership.phone_number);
    query.bindValue(":total_points", membership.total_points);
    query.bindValue(":status", membership.status);

    if (!query.exec()) {
        qDebug() << "Failed to insert membership:" << query.lastError().text();
        return false;
    }

    return true;
}

bool MembershipRepository::update(const Membership &membership)
{
    QSqlQuery query(m_db);
    query.prepare(R"(
        UPDATE memberships
        SET phone_number = :phone_number,
            status = :status,
            updated_at = CURRENT_TIMESTAMP
        WHERE id = :id
    )");

    query.bindValue(":phone_number", membership.phone_number);
    query.bindValue(":status", membership.status);
    query.bindValue(":id", membership.id);

    if (!query.exec()) {
        qDebug() << "Failed to update membership:" << query.lastError().text();
        return false;
    }

    return query.numRowsAffected() > 0;
}

// operation => add/subtract
bool MembershipRepository::adjustPoints(const int &id, const QString &operation, const int &points)
{
    if (points < 0) {
        qDebug() << "Points to adjust must be non-negative.";
        return false;
    }

    QString sql;
    if (operation == "add") {
        sql = R"(
            UPDATE memberships
            SET total_points = total_points + :points,
                updated_at = CURRENT_TIMESTAMP
            WHERE id = :id
        )";
    } else if (operation == "subtract") {
        sql = R"(
            UPDATE memberships
            SET total_points = MAX(total_points - :points, 0),
                updated_at = CURRENT_TIMESTAMP
            WHERE id = :id
        )";
    } else {
        qDebug() << "Invalid operation. Must be 'add' or 'subtract'.";
        return false;
    }

    QSqlQuery query(m_db);
    query.prepare(sql);
    query.bindValue(":points", points);
    query.bindValue(":id", id);

    if (!query.exec()) {
        qDebug() << "Failed to adjust points:" << query.lastError().text();
        return false;
    }

    return query.numRowsAffected() > 0;
}

QList<Membership> MembershipRepository::getMembershipsByStatus(const QString &status)
{
    QList<Membership> memberships;

    QSqlQuery query(m_db);
    query.prepare(R"(
        SELECT id, phone_number, total_points, status
        FROM memberships
        WHERE status = :status
    )");
    query.bindValue(":status", status);

    if (!query.exec()) {
        qDebug() << "Failed to fetch memberships by status:" << query.lastError().text();
        return memberships;
    }

    while (query.next()) {
        Membership membership;
        membership.id = query.value("id").toInt();
        membership.phone_number = query.value("phone_number").toString();
        membership.total_points = query.value("total_points").toInt();
        membership.status = query.value("status").toString();
        memberships.append(membership);
    }

    return memberships;
}

bool MembershipRepository::remove(const int &id)
{
    QSqlQuery query(m_db);
    query.prepare(R"(
        DELETE FROM memberships
        WHERE id = :id
    )");

    query.bindValue(":id", id);

    if (!query.exec()) {
        qDebug() << "Failed to delete membership:" << query.lastError().text();
        return false;
    }

    return query.numRowsAffected() > 0;
}
