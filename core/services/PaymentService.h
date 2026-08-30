#ifndef PAYMENTSERVICE_H
#define PAYMENTSERVICE_H

#include <QList>
#include <QString>
#include "data/PaymentRepository.h"

#include "../domain/Payment.h"
#include "../domain/PaymentRequest.h"

class PaymentService
{
public:
    explicit PaymentService(PaymentRepository &paymentRepository);

    bool recordPayments(int orderSessionId, const QList<PaymentRequest> &payments);
    std::optional<Payment> getPayment(int paymentId) const;
    QList<Payment> getPaymentsForOrderSession(int orderSessionId) const;

private:
    PaymentRepository &m_paymentRepository;
};

#endif // PAYMENTSERVICE_H
