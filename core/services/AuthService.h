#ifndef AUTHSERVICE_H
#define AUTHSERVICE_H

#include <QObject>
#include <optional>
#include <QString>
#include "../domain/User.h"
#include "../data/UserRepository.h"

class AuthService : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString currentUsername READ currentUsername NOTIFY currentUserChanged)
    Q_PROPERTY(QString currentUserRole  READ currentUserRole NOTIFY currentUserChanged)

public:
    explicit AuthService(UserRepository &repo);

    Q_INVOKABLE bool login(const QString &username, const QString &password);
    Q_INVOKABLE bool registerUser(const QString &username,
                                  const QString &password,
                                  const QString &passwordConfirm);
    Q_INVOKABLE void logout();

    Q_INVOKABLE bool isFirstAdminSetupNeeded() const;

    std::optional<User> currentUser() const;

    Q_INVOKABLE QString currentUsername() const;
    Q_INVOKABLE QString currentUserRole() const;

signals:
    void currentUserChanged();

private:
    QString hashPassword(const QString &password) const;

private:
    UserRepository &m_repo;
    std::optional<User> m_currentUser;
};

#endif // AUTHSERVICE_H
