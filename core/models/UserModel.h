#ifndef USERMODEL_H
#define USERMODEL_H

#include <QAbstractListModel>
#include <QVector>
#include "../domain/User.h"
#include "../data/UserRepository.h"

class UserModel : public QAbstractListModel
{
    Q_OBJECT

public:
    enum Roles {
        IdRole = Qt::UserRole + 1,
        UsernameRole,
        RoleRole,
        ActiveRole
    };

    explicit UserModel(UserRepository &repo, QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE void reload();
    Q_INVOKABLE void deactivateUser(int userId);

private:
    UserRepository &m_repo;
    QVector<User> m_data;
};

#endif // USERMODEL_H
