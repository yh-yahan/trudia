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

QVariantList OrderService::getOpenOrders()
{
    QVariantList result;

    auto orders = m_orderRepo.getActiveOrderSessionOrders();

    for (const auto &order : orders) {
        QVariantMap map;

        map["id"] = order.id;
        map["display_number"] = order.display_number;
        map["status"] = order.status;
        map["notes"] = order.notes;
        map["type"] = order.order_type;

        if (order.table_id.has_value())
            map["table_id"] = order.table_id.value();
        else
            map["table_id"] = QVariant();

        result.append(map);
    }

    return result;
}

QVariantList OrderService::getOrderItems(int orderId)
{
    QVariantList result;

    auto items = m_orderItemRepo.getOrderItemsByOrderId(orderId);

    for (const auto &item : items) {
        QVariantMap map;

        map["id"] = item.id;
        map["item_id"] = item.item_id;
        map["item_name"] = item.item_name;
        map["quantity"] = item.quantity;
        map["price"] = item.price / 100;
        map["status"] = item.item_status;
        map["notes"] = item.notes;

        result.append(map);
    }

    return result;
}

int OrderService::updateOrder(
    int orderId,
    const QString &orderType,
    const QVariantList &items,
    const QVariantMap &options)
{
    if (items.isEmpty())
    {
        qWarning() << "updateOrder failed: empty items";
        return -1;
    }

    QSqlDatabase db = QSqlDatabase::database();
    db.transaction();

    // load order
    auto orderOpt = m_orderRepo.getOrderById(orderId);
    if (!orderOpt.has_value())
    {
        qWarning() << "updateOrder failed: order not found";
        db.rollback();
        return -1;
    }

    Order order = orderOpt.value();
    int orderSessionId = order.order_session_id;

    // load order session
    auto sessionOpt = m_orderSessionRepo.getById(orderSessionId);
    if (!sessionOpt.has_value())
    {
        qWarning() << "updateOrder failed: session not found";
        db.rollback();
        return -1;
    }

    OrderSession session = sessionOpt.value();

    // table change
    std::optional<int> newTableId;
    if (options.contains("tableId") && !options["tableId"].isNull())
        newTableId = options["tableId"].toInt();

    if (session.table_id != newTableId)
    {
        if (session.table_id.has_value())
            m_tableRepo.setTableState(session.table_id.value(), false);

        if (newTableId.has_value())
            m_tableRepo.setTableState(newTableId.value(), true);

        session.table_id = newTableId;
    }

    // order type
    session.order_type = orderType;

    // order metadata
    order.notes = options.value("notes").toString();
    m_orderRepo.update(order);

    // replace items
    m_orderItemRepo.removeByOrderId(orderId);

    for (const QVariant &v : items) {
        QVariantMap m = v.toMap();

        int menuId = m["menuItemId"].toInt();

        auto menuOpt = m_menuRepo.getMenuItemById(menuId);
        if (!menuOpt.has_value()) {
            qWarning() << "Menu item not found:" << menuId;
            continue;
        }

        const Menu &menu = menuOpt.value();

        if (!menu.is_available) {
            qWarning() << "Menu unavailable:" << menuId;
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

        m_orderItemRepo.create(item);
    }

    // recompute session totals
    auto orders = m_orderRepo.getOrdersBySessionId(orderSessionId);

    double newSubtotal = 0.0;

    for (const auto &o : orders)
    {
        auto orderItems = m_orderItemRepo.getOrderItemsByOrderId(o.id);

        for (const auto &item : orderItems)
        {
            newSubtotal += item.quantity * item.price;
        }
    }

    session.subtotal = newSubtotal;
    session.tax = m_taxService.calculateTax(newSubtotal);
    session.total = session.subtotal + session.tax - session.discount;

    m_orderSessionRepo.update(session);

    if (!db.commit())
    {
        qCritical() << "updateOrder commit failed";
        db.rollback();
        return -1;
    }

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
