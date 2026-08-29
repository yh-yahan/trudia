#ifndef PAYMENTREPOSITORY_H
#define PAYMENTREPOSITORY_H

#include <QSqlDatabase>

#include "../domain/Payment.h"

class PaymentRepository
{
public:
    explicit PaymentRepository(QSqlDatabase db);

    std::optional<Payment> findById(int id) const;
    QList<Payment> findByOrderSessionId(int orderSessionId) const;

    bool create(Payment &payment);

private:
    QSqlDatabase m_db;
};

#endif // PAYMENTREPOSITORY_H
