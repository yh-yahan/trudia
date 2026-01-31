#include "UserRepository.h"

#include <QSqlQuery>
#include <QSqlError>
#include <QVariant>
#include <QDebug>

UserRepository::UserRepository(QSqlDatabase db): m_db(db) {}

std::optional<User> UserRepository::findByUsername(const QString &username)
{
    QSqlQuery query(m_db);
    query.prepare(R"(
        SELECT id, username, password, role
        FROM users
        WHERE username = :username
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

void UserRepository::createUser(const User &user)
{
    QSqlQuery query(m_db);
    query.prepare(R"(
        INSERT INTO users (username, password, role)
        VALUES (:username, :password, :role)
    )");

    query.bindValue(":username", user.username);
    query.bindValue(":password", user.password);
    query.bindValue(":role", user.role);

    if (!query.exec()) {
        qWarning() << "createUser failed:" << query.lastError();
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
