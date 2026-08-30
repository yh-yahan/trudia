#include "PaymentService.h"

#include "../data/PaymentRepository.h"
#include "../domain/PaymentRequest.h"
#include "../logging/LoggingCategories.h"

PaymentService::PaymentService(PaymentRepository& paymentRepository)
    : m_paymentRepository(paymentRepository) {}

bool PaymentService::recordPayments(int orderSessionId, const QList<PaymentRequest> &payments)
{
    if (orderSessionId <= 0)
    {
        qCWarning(logPayment)
            << "Invalid order session ID:"
            << orderSessionId;
        return false;
    }

    if (payments.isEmpty())
    {
        qCWarning(logPayment)
            << "No payments provided for order session:"
            << orderSessionId;
        return false;
    }

    for (const PaymentRequest& payment : payments)
    {
        if (payment.method.isEmpty())
        {
            qCWarning(logPayment) << "Payment method is empty";
            return false;
        }

        if (payment.amount <= 0)
        {
            qCWarning(logPayment) << "Invalid payment amount:" << payment.amount;
            return false;
        }

        Payment record;
        record.order_session_id = orderSessionId;
        record.method = payment.method;
        record.amount = payment.amount;
        record.type = "payment";

        if (!m_paymentRepository.create(record))
        {
            qCWarning(logPayment) << "Failed to record payment for order session:" << orderSessionId;
            return false;
        }
    }

    return true;
}

std::optional<Payment> PaymentService::getPayment(int paymentId) const
{
    if (paymentId <= 0) return std::nullopt;

    return m_paymentRepository.findById(paymentId);
}

QList<Payment> PaymentService::getPaymentsForOrderSession(int orderSessionId) const
{
    if (orderSessionId <= 0) return {};

    return m_paymentRepository.findByOrderSessionId(orderSessionId);
}
