#ifndef USERREPOSITORY_H
#define USERREPOSITORY_H

#include <QString>
#include <QSqlDatabase>
#include "../domain/User.h"

class UserRepository
{
public:
    explicit UserRepository(QSqlDatabase db);

    bool usernameExists(const QString& username);
    std::optional<User> findById(int id);
    std::optional<User> findByUsername(const QString &username);
    QList<User> getAll();

    void create(const User &user);
    void update(const User &user);
    void updatePassword(const User &user);
    void remove(int id);

    std::optional<bool> isEmpty() const;

private:
    QSqlDatabase m_db;
};

#endif // USERREPOSITORY_H
