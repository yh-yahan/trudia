#include "AuthService.h"

#include "../utilities/PasswordHasher.h"
#include "../logging/LoggingCategories.h"

AuthService::AuthService(UserRepository &userRepo)
    : m_userRepo(userRepo) {}

QString AuthService::currentUsername() const {
    return m_currentUser.has_value() ? m_currentUser->username : "";
}

QString AuthService::currentUserRole() const {
    return m_currentUser.has_value() ? m_currentUser->role : "";
}

bool AuthService::login(const QString &username, const QString &password)
{
    auto userOpt = m_userRepo.findByUsername(username);

    if (!userOpt) return false;

    const User &user = *userOpt;

    if (!PasswordHasher::verify(password, user.password)) return false;

    m_currentUser = user;
    return true;
}

bool AuthService::isFirstAdminSetupNeeded() const {
    auto emptyOpt = m_userRepo.isEmpty();

    if (!emptyOpt) {
        qCWarning(logAuth) << "Failed to check if users table is empty.";
        return false;
    }

    return emptyOpt.value();
}

std::optional<User> AuthService::currentUser() const
{
    return m_currentUser;
}

void AuthService::logout()
{
    m_currentUser.reset();
}
