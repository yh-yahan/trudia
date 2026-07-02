#ifndef RECEIPTSNAPSHOTREPOSITORY_H
#define RECEIPTSNAPSHOTREPOSITORY_H

#include <QString>
#include <QSqlDatabase>
#include "../domain/ReceiptSnapshot.h"

class ReceiptSnapshotRepository
{
public:
    explicit ReceiptSnapshotRepository(QSqlDatabase db);

    int create(const ReceiptSnapshot &snapshot);
    std::optional<ReceiptSnapshot> getByOrderSessionId(int orderSessionId);

private:
    QSqlDatabase m_db;
};

#endif // RECEIPTSNAPSHOTREPOSITORY_H
