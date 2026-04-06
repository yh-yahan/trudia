#include "UserModel.h"

UserModel::UserModel(UserRepository &repo, QObject *parent)
    : QAbstractListModel(parent), m_repo(repo)
{
}

int UserModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;

    return m_data.size();
}

QVariant UserModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_data.size())
        return {};

    const User &user = m_data[index.row()];

    switch (role) {
    case IdRole: return user.id;
    case UsernameRole: return user.username;
    case RoleRole: return user.role;
    case ActiveRole: return user.deactivated_at.isEmpty();
    }

    return {};
}

QHash<int, QByteArray> UserModel::roleNames() const
{
    return {
        { IdRole, "id" },
        { UsernameRole, "username" },
        { RoleRole, "role" },
        { ActiveRole, "active" }
    };
}

void UserModel::reload()
{
    beginResetModel();
    m_data = m_repo.getAll();
    endResetModel();
}

void UserModel::deactivateUser(int userId)
{
    m_repo.remove(userId);
    reload();
}
