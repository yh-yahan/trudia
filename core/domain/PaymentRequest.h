#ifndef PAYMENTREQUEST_H
#define PAYMENTREQUEST_H

#include <QString>

struct PaymentRequest {
    QString method;
    int amount;
};

#endif // PAYMENTREQUEST_H
