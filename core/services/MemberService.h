#ifndef MEMBERSERVICE_H
#define MEMBERSERVICE_H

#include <QObject>
#include <database/DatabaseManager.h>
#include "../models/MemberListModel.h"
#include "../models/MemberTransactionModel.h"
#include "../data/MembershipRepository.h"
#include "../data/MembershipTransactionRepository.h"

class MemberService : public QObject
{
    Q_OBJECT
public:
    explicit MemberService(DatabaseManager &dbManager,
        MembershipRepository &membershipRepo,
        MembershipTransactionRepository &membershipTransactionRepo,
        QObject *parent = nullptr);

    Q_PROPERTY(
        MemberListModel* membersModel
        READ membersModel
        CONSTANT
    )

    Q_PROPERTY(
        MemberTransactionModel* transactionModel
        READ transactionModel
        CONSTANT
    )

    MemberListModel *membersModel();
    MemberTransactionModel *transactionModel();

    Q_INVOKABLE void loadMembers();
    Q_INVOKABLE void searchMembers(const QString &query);

    Q_INVOKABLE bool manualAddPoints(int memberId, int points);
    Q_INVOKABLE bool manualRedeemPoints(int memberId, int points);

    Q_INVOKABLE bool editMember(int memberId, const QString &phoneNumber);
    Q_INVOKABLE bool revokeMember(int memberId);

    Q_INVOKABLE QVariantMap getMemberDetails(int memberId);

    Q_INVOKABLE void loadTransactions(int memberId);

private:
    DatabaseManager &m_dbManager;
    MembershipRepository &m_membershipRepo;
    MembershipTransactionRepository &m_membershipTransactionRepo;

    MemberListModel m_membersModel;
    MemberTransactionModel m_transactionModel;
};

#endif // MEMBERSERVICE_H
