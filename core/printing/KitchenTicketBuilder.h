#ifndef KITCHENTICKETBUILDER_H
#define KITCHENTICKETBUILDER_H

#include <QByteArray>
#include <QString>
#include <QDateTime>
#include "../domain/Order.h"
#include "../domain/OrderItem.h"
#include "../domain/OrderSession.h"
#include "../domain/Printer.h"

class KitchenTicketBuilder
{
public:
    explicit KitchenTicketBuilder();

    QByteArray build(const Order &order,
                     const OrderSession &orderSession,
                     const std::vector<OrderItem> &items,
                     const Printer &printer);
};

#endif // KITCHENTICKETBUILDER_H
