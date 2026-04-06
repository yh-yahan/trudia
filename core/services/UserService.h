#ifndef USERSERVICE_H
#define USERSERVICE_H

#include <QObject>
#include <QString>
#include <QVariantList>
#include <QtConcurrent>
#include "../data/UserRepository.h"

class UserModel;

class UserService : public QObject
{
    Q_OBJECT

    Q_PROPERTY(UserModel* userModel READ userModel CONSTANT)

public:
    explicit UserService(UserRepository &userRepo, QObject *parent = nullptr);

    UserModel* userModel() const;

    Q_INVOKABLE void createUser(QString username,
                                QString password,
                                QString confirm,
                                QString role);

    Q_INVOKABLE bool updateUser(int userId,
                                const QString &username,
                                const QString &role);

    Q_INVOKABLE bool changePassword(int userId,
                                    const QString &oldPassword,
                                    const QString &newPassword,
                                    const QString &newPasswordConfirm);

    Q_INVOKABLE bool deactivateUser(int userId);

signals:
    void createUserFinished(bool success);
    void usersChanged();

private:
    bool createUserInternal(const QString &username,
                            const QString &password,
                            const QString &confirm,
                            const QString &role);

private:
    UserRepository &m_userRepo;
    UserModel *m_userModel;
};

#endif
