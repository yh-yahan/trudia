#ifndef KITCHENTICKETBUILDER_H
#define KITCHENTICKETBUILDER_H

#include <QByteArray>
#include <QString>
#include <QDateTime>
#include "../domain/Order.h"
#include "../domain/OrderItem.h"
#include "../domain/OrderSession.h"
#include "../services/SettingService.h"

class KitchenTicketBuilder
{
public:
    explicit KitchenTicketBuilder(SettingService &settingService);

    QByteArray build(const Order &order,
                     const OrderSession &orderSession,
                     const std::vector<OrderItem> &items);

private:
    SettingService &m_settingService;
};

#endif // KITCHENTICKETBUILDER_H
