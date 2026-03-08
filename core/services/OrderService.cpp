#include "OrderService.h"

#include <QDate>
#include <QRandomGenerator>

OrderService::OrderService(OrderSessionRepository &orderSessionRepo,
                           OrderRepository &orderRepo,
                           OrderItemRepository &orderItemRepo,
                           TableRepository &tableRepo,
                           MenuRepository &menuRepo,
                           TaxCalculationService &taxService)
    : m_orderSessionRepo(orderSessionRepo),
      m_orderRepo(orderRepo),
      m_orderItemRepo(orderItemRepo),
      m_tableRepo(tableRepo),
      m_menuRepo(menuRepo),
      m_taxService(taxService) {}

int OrderService::createOrder(
    const QString &orderType,
    const QVariantList &items,
    const QVariantMap &options)
{
    if (items.isEmpty())
    {
        qWarning() << "createOrder failed: empty order";
        return -1;
    }

    int orderSessionId = -1;
    OrderSession orderSession;

    if (orderType == "dine_in")
    {
        // findOpenSessionByTableId returns 0 if not found, if found, returns order session id
        int existingSessionId = m_orderSessionRepo.findOpenSessionByTableId(options.value("tableId").toInt());
        if (existingSessionId > 0)
        {
            orderSessionId = existingSessionId;
            orderSession = m_orderSessionRepo.getById(orderSessionId).value();
        }
        else
        {
            // create a new session
            orderSession.table_id = options.value("tableId").toInt();
            orderSession.display_number = generateOrderSessionDisplayNumber();
            orderSession.order_type = orderType;
            orderSession.status = "open";
            orderSession.subtotal = 0.0;
            orderSession.tax = 0.0;
            orderSession.discount = 0.0;
            orderSession.total = 0.0;

            orderSessionId = m_orderSessionRepo.create(orderSession);
            m_tableRepo.setTableState(orderSession.table_id.value(), true);
            if (orderSessionId <= 0)
            {
                qCritical() << "OrderSession creation failed, aborting order creation";
                return -1;
            }

            orderSession.id = orderSessionId;
        }
    }
    else
    {
        orderSession.display_number = generateOrderSessionDisplayNumber();
        orderSession.order_type = orderType;
        orderSession.status = "open";
        orderSession.subtotal = 0.0;
        orderSession.tax = 0.0;
        orderSession.discount = 0.0;
        orderSession.total = 0.0;

        orderSessionId = m_orderSessionRepo.create(orderSession);
        if (orderSessionId <= 0)
        {
            qCritical() << "OrderSession creation failed, aborting order creation";
            return -1;
        }

        orderSession.id = orderSessionId;
    }

    // create order
    Order order;
    order.display_number = generateOrderDisplayNumber();
    order.order_session_id = orderSessionId;
    order.status = "pending";
    order.notes = options.value("notes").toString();

    int orderId = m_orderRepo.create(order);

    // create order items
    double subtotal = 0.0;
    for (const QVariant &v : items)
    {
        QVariantMap m = v.toMap();

        int menuId = m["menuItemId"].toInt();

        auto menuOpt = m_menuRepo.getMenuItemById(menuId);
        if (!menuOpt.has_value())
        {
            qWarning() << "Menu item not found:" << menuId;
            continue;
        }

        const Menu &menu = menuOpt.value();

        if (!menu.is_available)
        {
            qWarning() << "Menu item unavailable:" << menuId;
            continue;
        }

        OrderItem item;
        item.order_id = orderId;
        item.item_id = menu.id;
        item.item_name = menu.item;
        item.quantity = m["qty"].toInt();
        item.price = menu.price;
        item.notes = m["notes"].toString();
        item.item_status = "pending";

        subtotal += item.quantity * item.price;

        m_orderItemRepo.create(item);
    }

    orderSession.subtotal += subtotal;
    orderSession.tax = m_taxService.calculateTax(orderSession.subtotal);
    orderSession.discount = 0.0;
    orderSession.total = orderSession.subtotal + orderSession.tax - orderSession.discount;

    m_orderSessionRepo.update(orderSession);

    return orderId;
}

int OrderService::generateOrderSessionDisplayNumber()
{
    QString today = QDate::currentDate().toString("yyyy-MM-dd");

    int maxDisplay = m_orderSessionRepo.getMaxDisplayNumberForDate(today);
    if (maxDisplay == 0)
    {
        return QRandomGenerator::global()->bounded(4000, 8000);
    }
    else
    {
        int nextNumber = maxDisplay + 1;
        if (nextNumber > 9999)
            nextNumber = 4000;
        return nextNumber;
    }
}

int OrderService::generateOrderDisplayNumber()
{
    QString today = QDate::currentDate().toString("yyyy-MM-dd");

    int maxDisplay = m_orderRepo.getMaxDisplayNumberForDate(today);
    if (maxDisplay == 0)
    {
        return QRandomGenerator::global()->bounded(4000, 8000);
    }
    else
    {
        int nextNumber = maxDisplay + 1;
        if (nextNumber > 9999)
            nextNumber = 4000;
        return nextNumber;
    }
}
