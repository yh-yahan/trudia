#ifndef MEMBERSERVICE_H
#define MEMBERSERVICE_H

#include <QObject>
#include "../models/MemberListModel.h"
#include "../data/MembershipRepository.h"

class MemberService : public QObject
{
    Q_OBJECT
public:
    explicit MemberService(MembershipRepository &membershipRepository, QObject *parent = nullptr);
    Q_PROPERTY(
        MemberListModel* membersModel
        READ membersModel
        CONSTANT
    )

    MemberListModel *membersModel();

    Q_INVOKABLE void loadMembers();
    Q_INVOKABLE void searchMembers(const QString &query);

private:
    MembershipRepository &m_membershipRepository;

    QVariantMap memberToVariant(const Membership &member);

    MemberListModel m_membersModel;
};

#endif // MEMBERSERVICE_H
