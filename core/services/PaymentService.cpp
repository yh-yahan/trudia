#include "PaymentService.h"

#include "../data/PaymentRepository.h"
#include "../logging/LoggingCategories.h"

PaymentService::PaymentService(PaymentRepository& paymentRepository)
    : m_paymentRepository(paymentRepository) {}

bool PaymentService::recordPayment(int orderSessionId, const QString& method, int amount)
{
    if (orderSessionId <= 0)
    {
        qCWarning(logPayment) << "Invalid order session ID:" << orderSessionId;
        return false;
    }

    if (method.isEmpty())
    {
        qCWarning(logPayment) << "Payment method is empty";
        return false;
    }

    if (amount <= 0)
    {
        qCWarning(logPayment) << "Invalid payment amount:" << amount;
        return false;
    }

    Payment payment;
    payment.order_session_id = orderSessionId;
    payment.method = method;
    payment.amount = amount;
    payment.type = "payment";

    if (!m_paymentRepository.create(payment))
    {
        qCWarning(logPayment)
            << "Failed to record payment for order session:"
            << orderSessionId;
        return false;
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
