#ifndef KITCHENTICKETBUILDER_H
#define KITCHENTICKETBUILDER_H

#include <QByteArray>
#include <QString>
#include <QDateTime>
#include "../data/RegionalSettingsRepository.h"
#include "../domain/Order.h"
#include "../domain/OrderItem.h"
#include "../domain/OrderSession.h"
#include "../domain/OrderItemModifier.h"
#include "../domain/Printer.h"

class KitchenTicketBuilder
{
public:
    explicit KitchenTicketBuilder(RegionalSettingsRepository &regionalSettingsRepo);

    QByteArray build(const Order &order,
                     const OrderSession &orderSession,
                     const std::vector<OrderItem> &items,
                     const QMap<int, std::vector<OrderItemModifier>> &modifiersByItem,
                     const Printer &printer);

private:
    RegionalSettingsRepository &m_regionalSettingsRepo;
    QLocale getLocale() const;
};

#endif // KITCHENTICKETBUILDER_H
