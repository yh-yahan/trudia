#ifndef USERREPOSITORY_H
#define USERREPOSITORY_H

#include <QString>
#include <QSqlDatabase>
#include "../domain/User.h"

class UserRepository
{
public:
    explicit UserRepository(QSqlDatabase db);

    std::optional<User> findByUsername(const QString &username);
    void createUser(const User &user);
    std::optional<bool> isEmpty() const;

private:
    QSqlDatabase m_db;
};

#endif // USERREPOSITORY_H
