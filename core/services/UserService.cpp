#include "UserService.h"

#include "../utilities/PasswordHasher.h"
#include <QtConcurrentRun>

UserService::UserService(UserRepository &userRepo)
    : m_userRepo(userRepo) {}

QVariantList UserService::getAllUsers()
{
    QVariantList list;

    QList<User> users = m_userRepo.getAll();

    for (const User &u : users) {
        QVariantMap item;
        item["id"] = u.id;
        item["username"] = u.username;
        item["role"] = u.role;
        item["deactivated_at"] = u.deactivated_at;
        item["active"] = u.deactivated_at.isEmpty();

        list.append(item);
    }

    return list;
}

void UserService::createUser(QString username,
                             QString password,
                             QString confirm,
                             QString role)
{
    QtConcurrent::run([=]() {

        bool success = createUserInternal(username, password, confirm, role);

        QMetaObject::invokeMethod(
            this,
            [=]() { emit createUserFinished(success); },
            Qt::QueuedConnection
            );

    });
}

bool UserService::updateUser(
    int userId,
    const QString &username,
    const QString &role)
{
    auto userOpt = m_userRepo.findById(userId);
    if (!userOpt.has_value())
        return false;

    QString name = username.trimmed();
    if (name.isEmpty())
        return false;

    User user = userOpt.value();
    user.username = name;
    user.role = role;

    m_userRepo.update(user);

    return true;
}

bool UserService::changePassword(
    int userId,
    const QString &oldPassword,
    const QString &newPassword,
    const QString &newPasswordConfirm)
{
    auto userOpt = m_userRepo.findById(userId);
    if (!userOpt.has_value())
        return false;

    User user = userOpt.value();

    if (!PasswordHasher::verify(oldPassword, user.password))
        return false;

    if (newPassword.isEmpty())
        return false;

    if (newPassword != newPasswordConfirm)
        return false;

    user.password = PasswordHasher::hash(newPassword);

    m_userRepo.updatePassword(user);

    return true;
}

bool UserService::deactivateUser(int userId)
{
    auto userOpt = m_userRepo.findById(userId);
    if (!userOpt.has_value())
        return false;

    m_userRepo.remove(userId);

    return true;
}

bool UserService::createUserInternal(const QString &username,
                                     const QString &password,
                                     const QString &confirm,
                                     const QString &role)
{
    QString name = username.trimmed();
    if (name.isEmpty())
        return false;

    if (password.isEmpty())
        return false;

    if (password != confirm)
        return false;

    auto emptyOpt = m_userRepo.isEmpty();
    if (!emptyOpt.has_value())
        return false;

    bool isEmpty = emptyOpt.value();

    QString finalRole = role;
    if (isEmpty)
        finalRole = "admin";

    if (m_userRepo.usernameExists(name))
        return false;

    User user;
    user.username = name;
    user.password = PasswordHasher::hash(password);
    user.role = finalRole;

    m_userRepo.create(user);

    return true;
}
