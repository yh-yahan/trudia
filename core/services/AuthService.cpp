#include "AuthService.h"

#include <QCryptographicHash>

AuthService::AuthService(UserRepository &repo): m_repo(repo) {}

QString AuthService::currentUsername() const {
    return m_currentUser.has_value() ? m_currentUser->username : "";
}

QString AuthService::currentUserRole() const {
    return m_currentUser.has_value() ? m_currentUser->role : "";
}

bool AuthService::login(const QString &username, const QString &password)
{
    auto userOpt = m_repo.findByUsername(username);

    if (!userOpt) return false;

    const User &user = *userOpt;

    if (user.password != hashPassword(password)) return false;

    m_currentUser = user;
    return true;
}

bool AuthService::registerUser(const QString &username, const QString &password, const QString &passwordConfirm){
    auto emptyOpt = m_repo.isEmpty();
    if (!emptyOpt) return false;

    bool isEmpty = emptyOpt.value();

    if (password != passwordConfirm) return false;

    QString role = isEmpty ? "admin" : "user";

    if (!isEmpty) {
        if (!m_currentUser || m_currentUser->role != "admin")
            return false;
    }

    if (username.trimmed().isEmpty() || password.trimmed().isEmpty()) return false;

    if (m_repo.findByUsername(username)) return false;

    User u;
    u.username = username;
    u.password = hashPassword(password);
    u.role = role;

    m_repo.createUser(u);
    return true;
}

bool AuthService::isFirstAdminSetupNeeded() const {
    auto emptyOpt = m_repo.isEmpty();

    if (!emptyOpt) {
        qWarning() << "Failed to check if users table is empty.";
        return false;
    }

    return emptyOpt.value();
}

QString AuthService::hashPassword(const QString &password) const
{
    return QString(
        QCryptographicHash::hash(password.toUtf8(),QCryptographicHash::Sha256).toHex()
    );
}

std::optional<User> AuthService::currentUser() const
{
    return m_currentUser;
}

void AuthService::logout()
{
    m_currentUser.reset();
}
