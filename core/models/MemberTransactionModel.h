#ifndef MEMBERTRANSACTIONMODEL_H
#define MEMBERTRANSACTIONMODEL_H

#include <QAbstractListModel>
#include <vector>

#include "./MemberTransactionRow.h"

class MemberTransactionModel : public QAbstractListModel
{
    Q_OBJECT

public:
    enum Roles {
        IdRole = Qt::UserRole + 1,
        MembershipIdRole,
        OrderSessionIdRole,
        TypeRole,
        PointsRole,
        OrderDisplayNumberRole,
        CreatedAtRole
    };

    explicit MemberTransactionModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    void setTransactions(const std::vector<TransactionRow> &transactions);

private:
    std::vector<TransactionRow> m_transactions;
};

#endif // MEMBERTRANSACTIONMODEL_H
