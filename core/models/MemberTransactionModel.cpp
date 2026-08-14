#include "MemberTransactionModel.h"

#include <QDateTime>

MemberTransactionModel::MemberTransactionModel(QObject *parent)
    : QAbstractListModel(parent) {}

int MemberTransactionModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;

    return static_cast<int>(m_transactions.size());
}

QVariant MemberTransactionModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() ||
        index.row() < 0 ||
        index.row() >= static_cast<int>(m_transactions.size()))
    {
        return {};
    }

    const auto &row = m_transactions[index.row()];
    const auto &transaction = row.transaction;

    switch (role)
    {
    case IdRole:
        return transaction.id;

    case MembershipIdRole:
        return transaction.membership_id;

    case OrderSessionIdRole:
        return transaction.order_session_id;

    case TypeRole:
        return transaction.type;

    case PointsRole:
        return transaction.points;

    case OrderDisplayNumberRole:
        return row.orderDisplayNumber;

    case CreatedAtRole:
        return row.created_at.toLocalTime().toString("yyyy-MM-dd HH:mm:ss");

    default:
        return {};
    }
}

QHash<int, QByteArray> MemberTransactionModel::roleNames() const
{
    return {
        { IdRole, "id" },
        { MembershipIdRole, "membershipId" },
        { OrderSessionIdRole, "orderSessionId" },
        { TypeRole, "type" },
        { PointsRole, "points" },
        { OrderDisplayNumberRole, "orderDisplayNumber" },
        { CreatedAtRole, "createdAt" }
    };
}

void MemberTransactionModel::setTransactions(const std::vector<TransactionRow> &transactions)
{
    beginResetModel();
    m_transactions = transactions;
    endResetModel();
}
