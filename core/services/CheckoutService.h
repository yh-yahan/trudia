#ifndef CHECKOUTSERVICE_H
#define CHECKOUTSERVICE_H

#include <QVariantList>
#include <QObject>
#include <QString>
#include <QVariantMap>
#include "../data/OrderSessionRepository.h"
#include "../data/OrderRepository.h"
#include "../data/OrderItemRepository.h"

class CheckoutService : public QObject
{
    Q_OBJECT

public:
    explicit CheckoutService(OrderSessionRepository &orderSessionRepo,
                             OrderRepository &orderRepo,
                             OrderItemRepository &orderItemRepo);

    Q_INVOKABLE QVariantList getActiveOrdersForCheckout() const;
    Q_INVOKABLE bool markOrderPaid(const int &orderSessionId);
    Q_INVOKABLE QVariantList getCheckoutDetails(const int &orderSessionId);

private:
    OrderSessionRepository &m_orderSessionRepo;
    OrderRepository &m_orderRepo;
    OrderItemRepository &m_orderItemRepo;
};

#endif // CHECKOUTSERVICE_H
