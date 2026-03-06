#include "UserRepository.h"

#include <QSqlQuery>
#include <QSqlError>
#include <QVariant>
#include <QDebug>

UserRepository::UserRepository(QSqlDatabase db): m_db(db) {}

std::optional<User> UserRepository::findById(int id)
{
    QSqlQuery query(m_db);
    query.prepare(R"(
        SELECT id, username, password, role, deactivated_at
        FROM users
        WHERE id = :id
        AND (deactivated_at IS NULL OR deactivated_at = '')
        LIMIT 1
    )");

    query.bindValue(":id", id);

    if (!query.exec()) {
        qWarning() << "findById failed:" << query.lastError();
        return std::nullopt;
    }

    if (!query.next()) {
        return std::nullopt;
    }

    User u;
    u.id = query.value("id").toInt();
    u.username = query.value("username").toString();
    u.password = query.value("password").toString();
    u.role = query.value("role").toString();
    u.deactivated_at = query.value("deactivated_at").toString();

    return u;
}

bool UserRepository::usernameExists(const QString& username)
{
    QSqlQuery query(m_db);
    query.prepare(R"(
        SELECT 1
        FROM users
        WHERE username = :username
          AND (deactivated_at IS NULL OR deactivated_at = '')
        LIMIT 1
    )");

    query.bindValue(":username", username);

    if (!query.exec()) {
        qWarning() << "usernameExists failed:" << query.lastError();
        return false;
    }

    return query.next();
}

std::optional<User> UserRepository::findByUsername(const QString &username)
{
    QSqlQuery query(m_db);
    query.prepare(R"(
        SELECT id, username, password, role, deactivated_at
        FROM users
        WHERE username = :username
        AND (deactivated_at IS NULL OR deactivated_at = '')
    )");

    query.bindValue(":username", username);

    if (!query.exec()) {
        qWarning() << "findByUsername failed:" << query.lastError();
        return std::nullopt;
    }

    if (!query.next()) return std::nullopt;

    User u;
    u.id = query.value("id").toInt();
    u.username = query.value("username").toString();
    u.password = query.value("password").toString();
    u.role = query.value("role").toString();

    return u;
}

QList<User> UserRepository::getAll()
{
    QList<User> users;

    QSqlQuery query(m_db);
    if (!query.exec("SELECT id, username, role, deactivated_at FROM users")) {
        qDebug() << "Failed to fetch all users:" << query.lastError().text();
        return users;
    }

    while (query.next()) {
        User user;
        user.id = query.value("id").toInt();
        user.username = query.value("username").toString();
        user.role = query.value("role").toString();
        user.deactivated_at = query.value("deactivated_at").toString();
        users.append(user);
    }

    return users;
}

void UserRepository::create(const User &user)
{
    QSqlQuery query(m_db);
    query.prepare(R"(
        INSERT INTO users (username, password, role, deactivated_at)
        VALUES (:username, :password, :role, NULL)
    )");

    query.bindValue(":username", user.username);
    query.bindValue(":password", user.password);
    query.bindValue(":role", user.role);

    if (!query.exec()) {
        qWarning() << "createUser failed:" << query.lastError();
    }
}

void UserRepository::update(const User &user)
{
    QSqlQuery query(m_db);
    query.prepare(R"(
        UPDATE users
        SET username = :username,
        role = :role
        WHERE id = :user_id
    )");

    query.bindValue(":user_id", user.id);
    query.bindValue(":username", user.username);
    query.bindValue(":role", user.role);

    if (!query.exec()) {
        qWarning() << "update failed:" << query.lastError();
    }
}

void UserRepository::updatePassword(const User &user)
{
    QSqlQuery query(m_db);
    query.prepare(R"(
        UPDATE users
        SET password = :password
        WHERE id = :user_id
    )");

    query.bindValue(":user_id", user.id);
    query.bindValue(":password", user.password);

    if (!query.exec()) {
        qWarning() << "updatePassword failed:" << query.lastError();
    }
}

void UserRepository::remove(int id)
{
    QSqlQuery query(m_db);
    query.prepare(R"(
        UPDATE users
        SET deactivated_at = CURRENT_TIMESTAMP
        WHERE id = :user_id
    )");

    query.bindValue(":user_id", id);

    if (!query.exec()) {
        qWarning() << "remove failed:" << query.lastError();
    }
}

std::optional<bool> UserRepository::isEmpty() const {
    QSqlQuery query(m_db);
    query.prepare("SELECT 1 FROM users LIMIT 1");

    if (!query.exec()) {
        qWarning() << "isEmpty failed:" << query.lastError();
        return std::nullopt;
    }

    return !query.next();
}
