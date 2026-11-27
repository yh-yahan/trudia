#include "OrderService.h"

#include <QDate>
#include <QRandomGenerator>
#include <QSqlDatabase>
#include <QJsonDocument>
#include <QJsonArray>
#include "../enums/TableStatus.h"
#include "../enums/ReservationStatus.h"
#include "../logging/LoggingCategories.h"

namespace {
int modifierExtra(const QVariantList &modifiers)
{
    int extra = 0;
    for (const QVariant &value : modifiers) {
        const QVariantMap map = value.toMap();
        if (map.contains(QStringLiteral("priceDelta")))
            extra += (map.value(QStringLiteral("priceDelta")).toInt() * 100);
        else
            extra += (map.value(QStringLiteral("price_delta")).toInt() * 100);
    }
    return extra;
}

QString modifierGroupName(const QVariantMap &map)
{
    if (map.contains(QStringLiteral("groupName")))
        return map.value(QStringLiteral("groupName")).toString();
    return map.value(QStringLiteral("group_name")).toString();
}

std::optional<int> optionalId(const QVariantMap &map, const QStringList &keys)
{
    for (const QString &key : keys) {
        if (!map.contains(key))
            continue;
        const QVariant value = map.value(key);
        if (!value.isValid() || value.isNull())
            continue;
        const int id = value.toInt();
        if (id > 0)
            return id;
    }
    return std::nullopt;
}

QVariantMap modifierToMap(const OrderItemModifier &modifier)
{
    QVariantMap map;
    const QVariant modifierId = modifier.modifier_id.has_value()
                                    ? QVariant(*modifier.modifier_id)
                                    : QVariant();
    const QVariant groupId = modifier.group_id.has_value()
                                 ? QVariant(*modifier.group_id)
                                 : QVariant();

    map.insert(QStringLiteral("id"), modifierId);
    map.insert(QStringLiteral("modifier_id"), modifierId);
    map.insert(QStringLiteral("group_id"), groupId);
    map.insert(QStringLiteral("groupId"), groupId);
    map.insert(QStringLiteral("group_name"), modifier.group_name);
    map.insert(QStringLiteral("groupName"), modifier.group_name);
    map.insert(QStringLiteral("name"), modifier.name);
    map.insert(QStringLiteral("price_delta"), modifier.price_delta / 100);
    map.insert(QStringLiteral("priceDelta"), modifier.price_delta / 100);
    return map;
}

QVariantList modifiersForItem(OrderItemModifierRepository &repo, int orderItemId)
{
    QVariantList list;
    for (const auto &row : repo.getByOrderItemId(orderItemId))
        list.append(modifierToMap(row));
    return list;
}

QVariantList modifiersFromItem(const QVariantMap &item)
{
    const QString json = item.value(QStringLiteral("modifiersJson")).toString();
    if (!json.isEmpty()) {
        const QJsonDocument doc = QJsonDocument::fromJson(json.toUtf8());
        if (doc.isArray()) return doc.array().toVariantList();
    }

    const QVariant raw = item.value(QStringLiteral("modifiers"));
    if (raw.userType() == QMetaType::QVariantList) return raw.toList();
    if (raw.canConvert<QJsonArray>()) return raw.toJsonArray().toVariantList();

    return {};
}

QString resolvedGroupName(ModifiersRepository &modifiersRepo, const QVariantMap &map)
{
    QString name = modifierGroupName(map).trimmed();
    if (!name.isEmpty())
        return name;

    const auto groupId = optionalId(map, {QStringLiteral("groupId"),
                                          QStringLiteral("group_id")});
    if (!groupId.has_value())
        return QStringLiteral("Modifier");

    const auto group = modifiersRepo.getGroup(*groupId);
    if (group.has_value() && !group->name.trimmed().isEmpty())
        return group->name;

    return QStringLiteral("Modifier");
}

void saveOrderItemModifiers(OrderItemModifierRepository &repo,
                            ModifiersRepository &modifiersRepo,
                            int orderItemId,
                            const QVariantList &modifiers)
{
    for (const QVariant &value : modifiers) {
        const QVariantMap map = value.toMap();
        const QString name = map.value(QStringLiteral("name")).toString().trimmed();
        if (name.isEmpty()) {
            qCWarning(logOrder) << "Skipping modifier with empty name for order item" << orderItemId;
            continue;
        }

        OrderItemModifier row;
        row.order_item_id = orderItemId;
        row.modifier_id = optionalId(map, {QStringLiteral("modifierId"),
                                           QStringLiteral("modifier_id"),
                                           QStringLiteral("id")});
        row.group_id = optionalId(map, {QStringLiteral("groupId"),
                                        QStringLiteral("group_id")});
        row.group_name = resolvedGroupName(modifiersRepo, map);
        row.name = name;
        row.price_delta = map.contains(QStringLiteral("priceDelta"))
                              ? map.value(QStringLiteral("priceDelta")).toInt() * 100
                              : map.value(QStringLiteral("price_delta")).toInt() * 100;

        repo.create(row);
    }
}

QMap<int, std::vector<OrderItemModifier>> modifiersByOrderItems(
    OrderItemModifierRepository &repo,
    const std::vector<OrderItem> &items)
{
    QMap<int, std::vector<OrderItemModifier>> map;
    for (const auto &item : items)
        map.insert(item.id, repo.getByOrderItemId(item.id));
    return map;
}
} // namespace

OrderService::OrderService(OrderSessionRepository &orderSessionRepo,
                           OrderRepository &orderRepo,
                           OrderItemRepository &orderItemRepo,
                           TableRepository &tableRepo,
                           MenuRepository &menuRepo,
                           PrinterRepository &printerRepo,
                           OrderItemModifierRepository &orderItemModifierRepo,
                           ModifiersRepository &modifiersRepo,
                           TaxCalculationService &taxService,
                           KitchenTicketBuilder &kitchenTicketBuilder,
                           SettingService &settingService,
                           WindowsPrinterService &windowsPrinterService,
                           TableService &tableService,
                           ReservationService &reservationService,
                           CheckoutService &checkoutService,
                           InventoryService &inventoryService,
                           DatabaseManager &dbManager)
    : m_orderSessionRepo(orderSessionRepo),
      m_orderRepo(orderRepo),
      m_orderItemRepo(orderItemRepo),
      m_tableRepo(tableRepo),
      m_menuRepo(menuRepo),
      m_printerRepo(printerRepo),
      m_orderItemModifierRepo(orderItemModifierRepo),
      m_modifiersRepo(modifiersRepo),
      m_taxService(taxService),
      m_kitchenTicketBuilder(kitchenTicketBuilder),
      m_settingService(settingService),
      m_windowsPrinterService(windowsPrinterService),
      m_tableService(tableService),
      m_reservationService(reservationService),
      m_checkoutService(checkoutService),
      m_inventoryService(inventoryService),
      m_databaseManager(dbManager) {}

QVariantList OrderService::getOpenOrders()
{
    QVariantList result;

    auto orders = m_orderRepo.getActiveOrderSessionOrders();

    auto tables = m_tableRepo.getAllTables();
    QMap<int, QString> tableMap;

    for (const auto &table : tables)
        tableMap[table.id] = table.table_name;

    for (const auto &order : orders)
    {
        QVariantMap map;

        map["id"] = order.id;
        map["display_number"] = order.display_number;
        map["status"] = order.status;
        map["notes"] = order.notes;
        map["type"] = order.order_type;

        if (order.table_id.has_value()) {
            int tableId = order.table_id.value();
            map["table_name"] = tableMap.value(tableId);
            map["table_id"] = tableId;
        } else {
            map["table_name"] = QVariant();
        }

        result.append(map);
    }

    return result;
}

QVariantList OrderService::getOrderItems(int orderId)
{
    QVariantList result;

    auto items = m_orderItemRepo.getOrderItemsByOrderId(orderId);

    for (const auto &item : items)
    {
        QVariantMap map;

        map["id"] = item.id;
        map["item_id"] = item.item_id;
        map["item_name"] = item.item_name;
        map["quantity"] = item.quantity;
        map["price"] = item.price / 100;
        map["status"] = item.item_status;
        map["notes"] = item.notes;
        map["portion_size"] = item.portion_size;
        map["modifiers"] = modifiersForItem(m_orderItemModifierRepo, item.id);

        result.append(map);
    }

    return result;
}

int OrderService::createOrder(
    const QString &orderType,
    const QVariantList &items,
    const QVariantMap &options)
{
    if (items.isEmpty())
    {
        qCWarning(logOrder) << "createOrder failed: empty order";
        return -1;
    }

    int orderSessionId = -1;
    OrderSession orderSession;

    if (orderType == "dine_in")
    {
        int existingSessionId = m_orderSessionRepo.findOpenSessionByTableId(options.value("tableId").toInt());
        if (existingSessionId > 0)
        {
            orderSessionId = existingSessionId;
            orderSession = m_orderSessionRepo.getById(orderSessionId).value();
        }
        else
        {
            orderSession.table_id = options.value("tableId").toInt();
            orderSession.display_number = generateOrderSessionDisplayNumber();
            orderSession.order_type = orderType;
            orderSession.status = "open";
            orderSession.subtotal = 0.0;
            orderSession.tax = 0.0;
            orderSession.discount = 0.0;
            orderSession.total = 0.0;

            orderSessionId = m_orderSessionRepo.create(orderSession);
            m_tableService.setTableStatus(orderSession.table_id.value(), TableStatus::Occupied);
            if (orderSessionId <= 0)
            {
                qCritical() << "OrderSession creation failed, aborting order creation";
                return -1;
            }

            orderSession.id = orderSessionId;
        }

        const int tableId = orderSession.table_id.value();

        QVariantMap reservation = m_reservationService.getActiveReservationByTable(tableId);

        if (!reservation.isEmpty() && reservation["status"].toString() == toString(ReservationStatus::Booked))
        {
            reservation["status"] = toString(ReservationStatus::Seated);
            m_reservationService.updateReservation(reservation);
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

    const QString kitchenMode = m_settingService.kitchenMode();
    const bool usesKds = kitchenMode == "kds" || kitchenMode == "hybrid";
    const QString initialStatus = usesKds ? "pending" : "served";

    Order order;
    order.display_number = generateOrderDisplayNumber();
    order.order_session_id = orderSessionId;
    order.status = initialStatus;
    order.notes = options.value("notes").toString();

    int orderId = m_orderRepo.create(order);
    if (orderId <= 0)
    {
        qCWarning(logOrder) << "createOrder failed: could not create order";
        return -1;
    }

    for (const QVariant &v : items)
    {
        QVariantMap m = v.toMap();

        int menuId = m["menuItemId"].toInt();

        auto menuOpt = m_menuRepo.getMenuItemById(menuId);
        if (!menuOpt.has_value())
        {
            qCWarning(logOrder) << "Menu item not found:" << menuId;
            continue;
        }

        const Menu &menu = menuOpt.value();

        if (!menu.is_available)
        {
            qCWarning(logOrder) << "Menu item unavailable:" << menuId;
            continue;
        }

        const QVariantList modifiers = modifiersFromItem(m);

        OrderItem item;
        item.order_id = orderId;
        item.item_id = menu.id;
        item.item_name = menu.item;
        item.quantity = m["qty"].toInt();
        item.portion_size = menu.portion_size.value_or("");
        item.price = menu.price;
        item.is_taxable = menu.is_taxable;
        item.notes = m["notes"].toString();
        item.item_status = initialStatus;

        const int orderItemId = m_orderItemRepo.create(item);
        if (orderItemId <= 0)
        {
            qCWarning(logOrder) << "Failed to create order item for menu" << menuId;
            continue;
        }

        saveOrderItemModifiers(m_orderItemModifierRepo, m_modifiersRepo, orderItemId, modifiers);
    
        m_inventoryService.syncSaleStock(orderItemId);
    }

    m_checkoutService.recalculateSessionTotals(orderSessionId);

    auto settings = m_settingService.getKitchenSettings();

    if ((settings["mode"].toString() == "tickets" ||
        settings["mode"].toString() == "hybrid") &&
        settings["ticket_print_timing"].toString() == "order_created")
    {
        auto orderOpt = m_orderRepo.getOrderById(orderId);
        if (orderOpt.has_value())
        {
            auto sessionOpt = m_orderSessionRepo.getById(orderSessionId);
            if (sessionOpt.has_value())
            {
                auto printers = m_printerRepo.getAll();

                for (const auto &printer : printers)
                {
                    if (printer.role == "kitchen" || printer.role == "both")
                    {
                        auto printedItems = m_orderItemRepo.getOrderItemsByOrderId(orderId);
                        auto modifiers = modifiersByOrderItems(m_orderItemModifierRepo, printedItems);

                        QByteArray data = m_kitchenTicketBuilder.build(
                            orderOpt.value(),
                            sessionOpt.value(),
                            printedItems,
                            modifiers,
                            printer
                        );

                        if (!m_windowsPrinterService.print(printer.system_name, data))
                            qCWarning(logPrinter) << "Kitchen print failed.";
                    }
                }
            }
        }
    }

    emit orderCreated(orderId);

    return orderId;
}

int OrderService::updateOrder(
    int orderId,
    const QString &orderType,
    const QVariantList &items,
    const QVariantMap &options)
{
    if (items.isEmpty())
    {
        qCWarning(logOrder) << "updateOrder failed: empty items";
        return -1;
    }

    if (!m_databaseManager.beginTransaction())
    {
        qCWarning(logOrder) << "Failed to begin transaction";
        return -1;
    }

    auto rollback = [&]()
    {
        qCWarning(logOrder) << "Rolling back transaction";
        m_databaseManager.rollback();
        return -1;
    };

    auto orderOpt = m_orderRepo.getOrderById(orderId);
    if (!orderOpt.has_value())
    {
        qCWarning(logOrder) << "updateOrder failed: order not found";
        return rollback();
    }

    Order order = orderOpt.value();
    const int orderSessionId = order.order_session_id;

    auto sessionOpt = m_orderSessionRepo.getById(orderSessionId);
    if (!sessionOpt.has_value())
    {
        qCWarning(logOrder) << "updateOrder failed: session not found";
        return rollback();
    }

    OrderSession session = sessionOpt.value();

    std::optional<int> newTableId;
    if (options.contains("tableId") && !options["tableId"].isNull())
        newTableId = options["tableId"].toInt();

    if (session.table_id != newTableId)
    {
        if (session.table_id.has_value())
            m_tableService.setTableStatus(session.table_id.value(), TableStatus::Available);

        if (newTableId.has_value())
            m_tableService.setTableStatus(newTableId.value(), TableStatus::Occupied);

        session.table_id = newTableId;
    }

    session.order_type = orderType;
    order.notes = options.value("notes").toString();
    if (!m_orderRepo.update(order)) return rollback();

    const QString kitchenMode = m_settingService.kitchenMode();
    const bool usesKds = kitchenMode == "kds" || kitchenMode == "hybrid";
    const auto settings = m_settingService.getKitchenSettings();
    const bool printsOnCreate = (settings["mode"].toString() == "tickets" || settings["mode"].toString() == "hybrid")
        && settings["ticket_print_timing"].toString() == "order_created";
    const QString initialStatus = usesKds ? "pending" : "served";

    const auto existing = m_orderItemRepo.getOrderItemsByOrderId(orderId);
    QSet<int> keptIds;

    for (const QVariant &v : items)
    {
        const QVariantMap m = v.toMap();
        const int menuId = m["menuItemId"].toInt();
        const int existingId = m.value("orderItemId").toInt();
        const QVariantList modifiers = modifiersFromItem(m);

        auto menuOpt = m_menuRepo.getMenuItemById(menuId);
        if (!menuOpt.has_value())
        {
            qCWarning(logMenu) << "Menu item not found:" << menuId;
            continue;
        }

        const Menu &menu = menuOpt.value();
        if (!menu.is_available)
        {
            qCWarning(logMenu) << "Menu unavailable:" << menuId;
            continue;
        }

        if (existingId > 0)
        {
            auto itemOpt = m_orderItemRepo.getOrderItemById(existingId);
            if (!itemOpt.has_value() || itemOpt->order_id != orderId)
            {
                qCWarning(logOrder) << "Order item not found on order:" << existingId;
                return rollback();
            }

            OrderItem item = itemOpt.value();
            item.quantity = m["qty"].toInt();
            item.notes = m["notes"].toString();
            if (!m_orderItemRepo.update(item))
                return rollback();

            if (!m_orderItemModifierRepo.removeByOrderItemId(existingId))
                return rollback();
            saveOrderItemModifiers(m_orderItemModifierRepo, m_modifiersRepo, existingId, modifiers);

            if (!m_inventoryService.syncSaleStock(existingId)) return rollback();

            keptIds.insert(existingId);
            continue;
        }

        OrderItem item;
        item.order_id = orderId;
        item.item_id = menu.id;
        item.item_name = menu.item;
        item.quantity = m["qty"].toInt();
        item.portion_size = menu.portion_size.value_or("");
        item.price = menu.price;
        item.is_taxable = menu.is_taxable;
        item.notes = m["notes"].toString();
        item.item_status = initialStatus;

        const int orderItemId = m_orderItemRepo.create(item);
        if (orderItemId <= 0)
        {
            qCWarning(logOrder) << "Failed to create order item for menu" << menuId;
            return rollback();
        }

        saveOrderItemModifiers(m_orderItemModifierRepo, m_modifiersRepo, orderItemId, modifiers);

        if (!m_inventoryService.syncSaleStock(orderItemId)) return rollback();
    }

    for (const auto &oldItem : existing)
    {
        if (keptIds.contains(oldItem.id)) continue;

        OrderItem cleared = oldItem;
        cleared.quantity = 0;
        if (!m_orderItemRepo.update(cleared)) return rollback();
        if (!m_inventoryService.syncSaleStock(oldItem.id)) return rollback();
        if (!m_orderItemRepo.remove(oldItem.id)) return rollback();
    }

    if (!m_orderSessionRepo.update(session)) return rollback();

    m_checkoutService.recalculateSessionTotals(orderSessionId);

    if (!m_databaseManager.commit())
    {
        qCWarning(logOrder) << "Commit failed";
        return rollback();
    }

    if (printsOnCreate)
    {
        auto printedOrder = m_orderRepo.getOrderById(orderId);
        auto printedSession = m_orderSessionRepo.getById(orderSessionId);
        if (printedOrder.has_value() && printedSession.has_value())
        {
            const auto printers = m_printerRepo.getAll();
            for (const auto &printer : printers)
            {
                if (printer.role != "kitchen" && printer.role != "both")
                    continue;

                const auto printedItems = m_orderItemRepo.getOrderItemsByOrderId(orderId);
                const auto modifiers = modifiersByOrderItems(m_orderItemModifierRepo, printedItems);
                const QByteArray data = m_kitchenTicketBuilder.build(
                    printedOrder.value(),
                    printedSession.value(),
                    printedItems,
                    modifiers,
                    printer);

                if (!m_windowsPrinterService.print(printer.system_name, data))
                    qCWarning(logPrinter) << "Kitchen print failed";
            }
        }
    }

    emit orderUpdated(orderId);
    return orderId;
}

int OrderService::generateOrderSessionDisplayNumber()
{
    QString today = QDate::currentDate().toString("yyyy-MM-dd");

    int maxDisplay = m_orderSessionRepo.getMaxDisplayNumberForDate(today);
    if (maxDisplay == 0)
        return QRandomGenerator::global()->bounded(4000, 8000);

    int nextNumber = maxDisplay + 1;
    if (nextNumber > 9999)
        nextNumber = 4000;
    return nextNumber;
}

int OrderService::generateOrderDisplayNumber()
{
    QString today = QDate::currentDate().toString("yyyy-MM-dd");

    int maxDisplay = m_orderRepo.getMaxDisplayNumberForDate(today);
    if (maxDisplay == 0)
        return QRandomGenerator::global()->bounded(4000, 8000);

    int nextNumber = maxDisplay + 1;
    if (nextNumber > 9999)
        nextNumber = 4000;
    return nextNumber;
}

bool OrderService::printKitchenTicket(int orderId)
{
    auto orderOpt = m_orderRepo.getOrderById(orderId);
    if (!orderOpt.has_value())
    {
        qCWarning(logOrder) << "order not found" << orderId;
        return false;
    }

    const Order &order = orderOpt.value();

    auto sessionOpt = m_orderSessionRepo.getById(order.order_session_id);
    if (!sessionOpt.has_value())
    {
        qCWarning(logOrder) << "session not found" << order.order_session_id;
        return false;
    }

    auto items = m_orderItemRepo.getOrderItemsByOrderId(orderId);
    if (items.empty())
    {
        qCWarning(logOrder) << "no items found";
        return false;
    }

    auto printers = m_printerRepo.getAll();

    bool allOk = true;
    bool printed = false;

    for (const auto &printer : printers)
    {
        if (printer.role == "kitchen" || printer.role == "both")
        {
            printed = true;

            auto modifiers = modifiersByOrderItems(m_orderItemModifierRepo, items);

            QByteArray data = m_kitchenTicketBuilder.build(
                orderOpt.value(),
                sessionOpt.value(),
                items,
                modifiers,
                printer
            );

            if (!m_windowsPrinterService.print(printer.system_name, data))
                allOk = false;
        }
    }

    return printed && allOk;
}
