#include "MemberListModel.h"

MemberListModel::MemberListModel(QObject *parent)
    : QAbstractListModel(parent) {}

int MemberListModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)

    return m_members.count();
}

QVariant MemberListModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() ||
        index.row() >= m_members.count())
    {
        return {};
    }

    const Membership &member = m_members[index.row()];

    switch (role)
    {
    case IdRole:
        return member.id;
    case PhoneNumberRole:
        return member.phone_number;
    case TotalPointsRole:
        return member.total_points;
    case StatusRole:
        return member.status;
    }

    return {};
}

QHash<int, QByteArray> MemberListModel::roleNames() const
{
    return {
        {IdRole, "id"},
        {PhoneNumberRole, "phoneNumber"},
        {TotalPointsRole, "totalPoints"},
        {StatusRole, "status"}
    };
}

void MemberListModel::setMembers(const QList<Membership> &members)
{
    beginResetModel();

    m_members = members;

    endResetModel();
}
