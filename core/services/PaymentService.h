#ifndef PAYMENTSERVICE_H
#define PAYMENTSERVICE_H

#include <QList>
#include <QString>
#include "data/PaymentRepository.h"

#include "domain/Payment.h"

class PaymentService
{
public:
    explicit PaymentService(PaymentRepository &paymentRepository);

    bool recordPayment(int orderSessionId, const QString& method, int amount);
    std::optional<Payment> getPayment(int paymentId) const;
    QList<Payment> getPaymentsForOrderSession(int orderSessionId) const;

private:
    PaymentRepository &m_paymentRepository;
};

#endif // PAYMENTSERVICE_H
