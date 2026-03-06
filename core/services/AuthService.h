#ifndef AUTHSERVICE_H
#define AUTHSERVICE_H

#include <QObject>
#include <optional>
#include <QString>
#include "../domain/User.h"
#include "../data/UserRepository.h"

enum class Permission {
    Managements,
    ViewReports,
    CreateOrder,
    MarkKitchenOrderProgressions,
    Checkout,
    SystemConfig
};

static const QMap<QString, QSet<Permission>> ROLE_PERMISSIONS = {
    { "admin", {
        Permission::Managements,
        Permission::ViewReports,
        Permission::CreateOrder,
        Permission::MarkKitchenOrderProgressions,
        Permission::Checkout,
        Permission::SystemConfig
    }},
    { "service_staff", {
        Permission::CreateOrder,
        Permission::MarkKitchenOrderProgressions,
        Permission::Checkout
    }},
    { "kitchen_staff", {
        Permission::MarkKitchenOrderProgressions
    }}
};

class AuthService : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString currentUsername READ currentUsername NOTIFY currentUserChanged)
    Q_PROPERTY(QString currentUserRole  READ currentUserRole NOTIFY currentUserChanged)

public:
    explicit AuthService(UserRepository &userRepo);

    bool hasPermission(Permission permission) const;
    Q_INVOKABLE bool login(const QString &username, const QString &password);
    Q_INVOKABLE void logout();

    Q_INVOKABLE bool isFirstAdminSetupNeeded() const;

    std::optional<User> currentUser() const;

    Q_INVOKABLE QString currentUsername() const;
    Q_INVOKABLE QString currentUserRole() const;

signals:
    void currentUserChanged();

private:
    UserRepository &m_userRepo;
    std::optional<User> m_currentUser;
};

#endif // AUTHSERVICE_H
