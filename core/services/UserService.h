#ifndef USERSERVICE_H
#define USERSERVICE_H

#include <QObject>
#include <QFuture>
#include <QString>
#include "../data/UserRepository.h"

class UserService : public QObject
{
    Q_OBJECT

public:
    explicit UserService(UserRepository &userRepo);

    Q_INVOKABLE QVariantList getAllUsers();

    Q_INVOKABLE QFuture<bool> createUser(const QString &username,
                                const QString &password,
                                const QString &passwordConfirm,
                                const QString &role);
    Q_INVOKABLE bool updateUser(
        int userId,
        const QString &username,
        const QString &role
    );
    Q_INVOKABLE bool changePassword(
        int userId,
        const QString &oldPassword,
        const QString &newPassword,
        const QString &newPasswordConfirm
    );
    Q_INVOKABLE bool deactivateUser(int userId);

private:
    UserRepository &m_userRepo;
};

#endif // USERSERVICE_H
