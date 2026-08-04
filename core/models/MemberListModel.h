#ifndef MEMBERLISTMODEL_H
#define MEMBERLISTMODEL_H

#include <QAbstractListModel>
#include "../domain/Membership.h"

class MemberListModel : public QAbstractListModel
{
    Q_OBJECT

public:
    enum MemberRoles {
        IdRole = Qt::UserRole + 1,
        PhoneNumberRole,
        TotalPointsRole,
        StatusRole
    };

    explicit MemberListModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;
    void setMembers(const QList<Membership> &members);

private:
    QList<Membership> m_members;
};

#endif // MEMBERLISTMODEL_H
