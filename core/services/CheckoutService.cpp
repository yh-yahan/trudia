#include "CheckoutService.h"

#include <cmath>
#include <QTimeZone>
#include "../constants/TableStatus.h"
#include "../constants/ReservationStatus.h"
#include "../logging/LoggingCategories.h"

constexpr qint64 CURRENCY_SCALE = 100; // cents

CheckoutService::CheckoutService(OrderSessionRepository &orderSessionRepo,
                                 OrderRepository &orderRepo,
                                 OrderItemRepository &orderItemRepo,
                                 RestaurantRepository &restaurantRepo,
                                 PrinterRepository &printerRepo,
                                 TableRepository &tableRepo,
                                 MembershipRepository &membershipRepo,
                                 MembershipTransactionRepository &membershipTransactionRepo,
                                 TaxSettingsRepository &taxSettingsRepo,
                                 AppStateRepository &appStateRepo,
                                 ReceiptSnapshotRepository &receiptSnapshotRepo,
                                 RegionalSettingsRepository &regionalSettingsRepo,
                                 ReceiptBuilder &receiptBuilder,
                                 WindowsPrinterService &windowsPrinterService,
                                 TaxCalculationService &taxCalculationService,
                                 MembershipService &membershipService,
                                 SettingService &settingService,
                                 TableService &tableService,
                                 ReservationService &reservationService,
                                 AuthService &authService,
                                 DatabaseManager &databaseManager)
    : m_orderSessionRepo(orderSessionRepo),
      m_orderRepo(orderRepo),
      m_orderItemRepo(orderItemRepo),
      m_restaurantRepo(restaurantRepo),
      m_printerRepo(printerRepo),
      m_membershipRepo(membershipRepo),
      m_membershipTransactionRepo(membershipTransactionRepo),
      m_taxSettingsRepo(taxSettingsRepo),
      m_appStateRepo(appStateRepo),
      m_receiptSnapshotRepo(receiptSnapshotRepo),
      m_regionalSettingsRepo(regionalSettingsRepo),
      m_receiptBuilder(receiptBuilder),
      m_windowsPrinterService(windowsPrinterService),
      m_taxCalculationService(taxCalculationService),
      m_tableRepo(tableRepo),
      m_membershipService(membershipService),
      m_settingService(settingService),
      m_tableService(tableService),
      m_reservationService(reservationService),
      m_authService(authService),
      m_databaseManager(databaseManager) {}

bool CheckoutService::recalculateSessionTotals(int orderSessionId)
{
    auto sessionOpt = m_orderSessionRepo.getById(orderSessionId);
    if (!sessionOpt.has_value())
        return false;

    OrderSession session = sessionOpt.value();

    auto orders = m_orderRepo.getOrdersBySessionId(orderSessionId);

    QList<int> orderIds;
    for (const auto &order : orders)
        orderIds.append(order.id);

    auto items = m_orderItemRepo.getOrderItemsByOrderIds(orderIds);

    qint64 subtotal = 0;
    qint64 taxableSubtotal = 0;

    for (const auto &item : items)
    {
        const qint64 lineTotal = item.price * item.quantity;

        subtotal += lineTotal;

        if (item.is_taxable)
            taxableSubtotal += lineTotal;
    }

    TaxSettings settings;

    auto settingsOpt = m_taxSettingsRepo.get();
    if (settingsOpt)
    {
        settings = *settingsOpt;
    }
    else
    {
        settings.enabled = false;
        settings.rate = 0;
    }

    qint64 tax = m_taxCalculationService.calculateTax(
        taxableSubtotal,
        settings.rate,
        settings.enabled
    );

    session.subtotal = subtotal;
    session.tax = tax;

    session.total = subtotal + tax - session.discount;

    if (session.total < 0)
        session.total = 0;

    m_orderSessionRepo.update(session);

    return true;
}

QVariantList CheckoutService::loadActiveCheckoutSessions()
{
    QVariantList result;

    auto activeSessions = m_orderSessionRepo.getAllActiveOrderSessions();

    for (const auto &session : activeSessions)
    {
        recalculateSessionTotals(session.id);
    }

    activeSessions = m_orderSessionRepo.getAllActiveOrderSessions();

    auto tables = m_tableRepo.getAllTables();
    QMap<int, QString> tableMap;

    for (const auto &table : tables)
    {
        tableMap[table.id] = table.table_name;
    }

    for (const auto &session : activeSessions)
    {
        QVariantMap sessionMap;

        sessionMap["id"] = session.id;
        sessionMap["display_number"] = session.display_number;

        sessionMap["table_name"] =
            session.table_id.has_value()
                ? tableMap.value(session.table_id.value())
                : QVariant();

        sessionMap["order_type"] = session.order_type;
        sessionMap["status"] = session.status;

        sessionMap["subtotal"] = static_cast<double>(session.subtotal) / CURRENCY_SCALE;
        sessionMap["tax"] = static_cast<double>(session.tax) / CURRENCY_SCALE;
        sessionMap["discount"] = static_cast<double>(session.discount) / CURRENCY_SCALE;
        sessionMap["total"] = static_cast<double>(session.total) / CURRENCY_SCALE;

        sessionMap["opened_at"] =
            session.opened_at.has_value() ? session.opened_at.value() : QVariant();

        sessionMap["closed_at"] =
            session.closed_at.has_value() ? session.closed_at.value() : QVariant();

        result.append(sessionMap);
    }

    return result;
}

QVariantList CheckoutService::loadCheckoutDetails(const int &orderSessionId)
{
    QVariantList result;

    if (!recalculateSessionTotals(orderSessionId))
        return result;

    auto sessionOpt = m_orderSessionRepo.getById(orderSessionId);
    if (!sessionOpt.has_value())
        return result;

    const OrderSession session = sessionOpt.value();

    const auto orders = m_orderRepo.getOrdersBySessionId(orderSessionId);

    QList<int> orderIds;
    orderIds.reserve(orders.size());

    for (const auto &order : orders)
        orderIds.append(order.id);

    const auto items = m_orderItemRepo.getOrderItemsByOrderIds(orderIds);

    QMap<int, QVariantList> itemsByOrder;

    for (const auto &item : items)
    {
        QVariantMap itemMap;
        itemMap["id"] = item.id;
        itemMap["item_id"] = item.item_id;
        itemMap["item_name"] = item.item_name;
        itemMap["quantity"] = item.quantity;

        const double unitPrice = static_cast<double>(item.price) / CURRENCY_SCALE;

        itemMap["unit_price"] = unitPrice;
        itemMap["total_price"] = unitPrice * item.quantity;
        itemMap["item_status"] = item.item_status;
        itemMap["notes"] = item.notes;

        itemsByOrder[item.order_id].append(itemMap);
    }

    const double subtotal = static_cast<double>(session.subtotal) / CURRENCY_SCALE;
    const double tax = static_cast<double>(session.tax) / CURRENCY_SCALE;
    const double discount = static_cast<double>(session.discount) / CURRENCY_SCALE;
    const double total = static_cast<double>(session.total) / CURRENCY_SCALE;

    for (const auto &order : orders)
    {
        QVariantMap orderMap;
        orderMap["id"] = order.id;
        orderMap["display_number"] = order.display_number;
        orderMap["status"] = order.status;
        orderMap["notes"] = order.notes;
        orderMap["closed_at"] = order.closed_at.isEmpty() ? QVariant() : order.closed_at;
        orderMap["items"] = itemsByOrder.value(order.id);

        orderMap["subtotal"] = subtotal;
        orderMap["tax"] = tax;
        orderMap["discount"] = discount;
        orderMap["total"] = total;

        result.append(orderMap);
    }

    return result;
}

bool CheckoutService::completeCheckout(const int &orderSessionId, const QString &memberPhone, int pointsToRedeem)
{
    if (!m_databaseManager.beginTransaction())
    {
        qCWarning(logCheckout) << "Failed to begin transaction";
        return false;
    }

    auto rollback = [&]()
    {
        qCWarning(logCheckout) << "[Checkout] Rolling back transaction";
        m_databaseManager.rollback();
        return false;
    };

    if (!recalculateSessionTotals(orderSessionId))
    {
        qCWarning(logCheckout) << "[Checkout] Failed to recalculate totals";
        return rollback();
    }

    auto sessionOpt = m_orderSessionRepo.getById(orderSessionId);

    if (!sessionOpt.has_value())
    {
        qCWarning(logCheckout) << "Session not found:" << orderSessionId;
        return rollback();
    }

    OrderSession session = sessionOpt.value();

    if (session.status == "paid")
    {
        qCWarning(logCheckout) << "Session already paid";
        m_databaseManager.rollback();
        return true;
    }

    if (!applyMembershipToSession(session, memberPhone, pointsToRedeem))
    {
        qCWarning(logCheckout) << "Failed applying membership";
        return rollback();
    }

    if (!markOrdersServed(orderSessionId))
    {
        qCWarning(logCheckout) << "Failed marking orders served";
        return rollback();
    }

    if (!assignReceiptNumber(session))
    {
        qCWarning(logCheckout) << "Failed assigning receipt number";
        return rollback();
    }

    if (!m_orderSessionRepo.update(session))
    {
        qCWarning(logCheckout) << "Failed updating session";
        return rollback();
    }

    if (!m_orderSessionRepo.markAsPaid(orderSessionId))
    {
        qCWarning(logCheckout) << "Failed marking session paid";
        return rollback();
    }

    if (!freeTable(session))
    {
        qCWarning(logCheckout) << "Failed freeing table";
        return rollback();
    }

    if (!createReceiptSnapshot(session))
    {
        qCWarning(logCheckout) << "Failed creating receipt snapshot";
        return rollback();
    }

    if (!m_databaseManager.commit())
    {
        qCWarning(logCheckout) << "Commit failed";
        return false;
    }

    return true;
}

bool CheckoutService::printReceipt(int orderSessionId, const bool &isReprint)
{
    auto sessionOpt = m_orderSessionRepo.getById(orderSessionId);
    if (!sessionOpt.has_value())
        return false;

    const auto &session = sessionOpt.value();

    auto snapshotOpt = m_receiptSnapshotRepo.getByOrderSessionId(orderSessionId);

    if (!snapshotOpt)
        return false;

    const auto &snapshot = *snapshotOpt;

    ReceiptData data;
    data.cashierName = snapshot.cashier_name.value_or("");

    data.storeName = snapshot.store_name.value_or("");
    data.address = snapshot.address.value_or("");
    data.phone = snapshot.phone.value_or("");
    data.email = snapshot.email.value_or("");
    data.website = snapshot.website.value_or("");

    if (isReprint)
    {
        data.isReprint = true;
        QDateTime dt = QDateTime::fromString(
            snapshot.created_at.value_or(""),
            "yyyy-MM-dd HH:mm:ss"
        );

        dt.setTimeZone(QTimeZone::UTC);

        QDateTime local = dt.toLocalTime();

        auto settings = m_regionalSettingsRepo.get();

        QLocale locale;
        if (settings.has_value() && !settings->locale.isEmpty()) {
            locale = QLocale(settings->locale);
        }

        QString date = locale.toString(local.date(), QLocale::ShortFormat);
        QString time = local.time().toString("HH:mm:ss");

        data.checkoutAt = QString("%1 %2").arg(date, time);
    } 
    else
    {
        data.isReprint = false;
    }

    data.receiptNumber = session.receipt_number.value_or(QString());

    data.displayNumber = QString::number(session.display_number);

    if (session.order_type == "dine_in")
        data.orderType = QObject::tr("Dine In");
    else if (session.order_type == "takeout")
        data.orderType = QObject::tr("Takeout");
    else if (session.order_type == "delivery")
        data.orderType = QObject::tr("Delivery");
    else
        data.orderType = session.order_type;

    if (session.table_id.has_value())
    {
        auto tableOpt = m_tableRepo.getTableById(session.table_id.value());

        if (tableOpt.has_value())
            data.tableName = tableOpt->table_name;
    }

    data.taxName = snapshot.tax_name.value_or("");
    data.taxRate = snapshot.tax_rate.value_or(0);
    data.taxRegistrationNumber = snapshot.tax_registration_number.value_or("");

    data.subtotal = static_cast<double>(session.subtotal) / CURRENCY_SCALE;
    data.tax = static_cast<double>(session.tax) / CURRENCY_SCALE;
    data.total = static_cast<double>(session.total) / CURRENCY_SCALE;
    data.discount = static_cast<double>(session.discount) / CURRENCY_SCALE;

    auto orders = m_orderRepo.getOrdersBySessionId(orderSessionId);

    QList<int> orderIds;
    for (const auto &order : orders)
        orderIds.append(order.id);

    auto items = m_orderItemRepo.getOrderItemsByOrderIds(orderIds);

    struct GroupKey
    {
        QString name;
        qint64 price;

        bool operator<(const GroupKey &other) const
        {
            if (name != other.name)
                return name < other.name;
            return price < other.price;
        }
    };

    QMap<GroupKey, int> grouped;

    for (const auto &item : items)
    {
        GroupKey key{
            item.item_name,
            static_cast<qint64>(item.price)
        };

        grouped[key] += item.quantity;
    }

    for (auto it = grouped.begin(); it != grouped.end(); ++it)
    {
        ReceiptItem rItem;
        rItem.name = it.key().name;
        rItem.quantity = it.value();
        rItem.price = static_cast<double>(it.key().price) / CURRENCY_SCALE;

        data.items.append(rItem);
    }

    if (snapshot.member_phone.has_value())
    {
        data.memberPhone = snapshot.member_phone.value_or("");

        data.pointsBalanceBefore = snapshot.points_balance_before.value_or(0);
        data.pointsEarned = session.points_earned;
        data.pointsRedeemed = session.points_redeemed;
        data.pointsBalanceAfter = snapshot.points_balance_after.value_or(0);
    }

    auto printers = m_printerRepo.getAll();

    bool allOk = true;
    bool printed = false;

    for (const auto &printer : printers)
    {
        if (printer.role == "receipt" || printer.role == "both")
        {
            printed = true;

            QByteArray payload = m_receiptBuilder.build(data, printer);

            if (!m_windowsPrinterService.print(printer.system_name, payload))
                allOk = false;
        }
    }

    return printed && allOk;
}

QVariantList CheckoutService::getRecentPaidOrders() const
{
    QVariantList result;

    auto sessions = m_orderSessionRepo.getRecentPaidSessions(20);

    for (const auto &session : sessions)
    {
        QVariantMap map;

        map["id"] = session.id;
        map["display_number"] = session.display_number;
        map["total"] = session.total / 100;

        result.append(map);
    }

    return result;
}

bool CheckoutService::assignReceiptNumber(OrderSession &session)
{
    const int currentYear = QDate::currentDate().year();

    int storedYear = m_appStateRepo.get("receipt.year")
        .value_or(QString::number(currentYear))
        .toInt();

    int counter = m_appStateRepo.get("receipt.counter")
        .value_or("1")
        .toInt();

    if (storedYear != currentYear)
    {
        storedYear = currentYear;
        counter = 1;

        m_appStateRepo.set({
            "receipt.year",
            QString::number(currentYear)
        });
    }

    session.receipt_number = QString("%1-%2")
        .arg(storedYear)
        .arg(counter, 6, 10, QChar('0'));

    m_appStateRepo.set({
        "receipt.counter",
        QString::number(counter + 1)
    });

    return true;
}

QVariantMap CheckoutService::loadPaidOrderDetails(const int &orderSessionId) {
    QVariantMap result;

    auto sessionOpt = m_orderSessionRepo.getById(orderSessionId);

    if (!sessionOpt.has_value())
        return result;

    const OrderSession session = sessionOpt.value();

    const auto orders = m_orderRepo.getOrdersBySessionId(orderSessionId);

    QList<int> orderIds;
    orderIds.reserve(orders.size());

    for (const auto &order : orders)
        orderIds.append(order.id);

    const auto items = m_orderItemRepo.getOrderItemsByOrderIds(orderIds);

    QMap<int, QVariantList> itemsByOrder;

    for (const auto &item : items)
    {
        QVariantMap itemMap;

        itemMap["id"] = item.id;
        itemMap["item_id"] = item.item_id;
        itemMap["item_name"] = item.item_name;
        itemMap["quantity"] = item.quantity;

        const double unitPrice = static_cast<double>(item.price) / CURRENCY_SCALE;

        itemMap["unit_price"] = unitPrice;
        itemMap["total_price"] = unitPrice * item.quantity;

        itemMap["item_status"] = item.item_status;
        itemMap["notes"] = item.notes;

        itemsByOrder[item.order_id].append(itemMap);
    }

    QVariantMap sessionMap;

    sessionMap["id"] = session.id;
    sessionMap["display_number"] = session.display_number;

    sessionMap["subtotal"] = static_cast<double>(session.subtotal) / CURRENCY_SCALE;
    sessionMap["tax"] = static_cast<double>(session.tax) / CURRENCY_SCALE;
    sessionMap["discount"] = static_cast<double>(session.discount) / CURRENCY_SCALE;
    sessionMap["total"] = static_cast<double>(session.total) / CURRENCY_SCALE;

    // sessionMap["created_at"] = session.created_at;
    // sessionMap["closed_at"] = session.closed_at;

    QVariantList orderList;

    for (const auto &order : orders)
    {
        QVariantMap orderMap;

        orderMap["id"] = order.id;
        orderMap["display_number"] = order.display_number;
        orderMap["status"] = order.status;
        orderMap["notes"] = order.notes;

        orderMap["closed_at"] = order.closed_at.isEmpty() ? QVariant() : order.closed_at;

        orderMap["items"] = itemsByOrder.value(order.id);

        orderList.append(orderMap);
    }

    sessionMap["orders"] = orderList;

    return sessionMap;
}

bool CheckoutService::applyMembershipToSession(OrderSession &session, const QString &memberPhone, int pointsToRedeem)
{
    if (!m_settingService.membershipEnabled() || memberPhone.isEmpty())
        return true;

    MembershipResult result = m_membershipService.applyToOrder(
        session.id,
        memberPhone,
        session.subtotal,
        session.total,
        pointsToRedeem
    );

    if (!result.success)
        return false;

    session.discount += result.discount;
    session.total -= result.discount;

    session.points_redeemed = result.redeemedPoints;
    session.points_earned = result.earnedPoints;

    return true;
}

bool CheckoutService::markOrdersServed(int orderSessionId)
{
    auto orders = m_orderRepo.getOrdersBySessionId(orderSessionId);

    for (auto &order : orders)
    {
        order.status = "served";

        if (!m_orderRepo.update(order)) return false;

        if (!m_orderItemRepo.markItemsByOrderId(order.id, "served")) return false;
    }

    return true;
}

bool CheckoutService::createReceiptSnapshot(const OrderSession &session)
{
    auto restaurantOpt = m_restaurantRepo.get();

    if (!restaurantOpt.has_value())
        return false;

    ReceiptSnapshot receipt;

    receipt.order_session_id = session.id;
    receipt.cashier_name = m_authService.currentUsername();

    receipt.store_name = restaurantOpt->name;
    receipt.address = restaurantOpt->address;
    receipt.phone = restaurantOpt->phone_number.value_or("");
    receipt.email = restaurantOpt->email.value_or("");
    receipt.website = restaurantOpt->website.value_or("");

    auto taxOpt = m_taxSettingsRepo.get();

    if (taxOpt.has_value() && taxOpt->enabled)
    {
        receipt.tax_name = taxOpt->name;
        receipt.tax_rate = taxOpt->rate / 100;
        receipt.tax_registration_number =
            taxOpt->registration_number.value_or("");
    }
    else
    {
        receipt.tax_name = "";
        receipt.tax_rate = 0;
        receipt.tax_registration_number = "";
    }

    if (m_settingService.membershipEnabled())
    {
        int membershipId = m_membershipTransactionRepo.getMembershipIdBySession(session.id);

        if (membershipId > 0)
        {
            Membership membership =
                m_membershipRepo.getMembershipById(membershipId);

            int redeemed =
                m_membershipTransactionRepo.getRedeemedPoints(session.id);

            int earned =
                m_membershipTransactionRepo.getEarnedPoints(session.id);

            receipt.member_phone = membership.phone_number;
            receipt.points_balance_after = membership.total_points;
            receipt.points_balance_before =
                membership.total_points + redeemed - earned;
        }
    }

    receipt.order_type = session.order_type;

    if (session.table_id.has_value())
    {
        auto table = m_tableRepo.getTableById(session.table_id.value());

        if (table.has_value())
            receipt.table_name = table->table_name;
    }

    return m_receiptSnapshotRepo.create(receipt);
}

bool CheckoutService::freeTable(const OrderSession &session)
{
    if (!session.table_id.has_value())
        return true;

    int tableId = session.table_id.value();

    if (!m_tableRepo.setTableState(tableId, TableStatus::Available))
        return false;

    if (!m_tableService.setTableStatus(tableId, TableStatus::Available))
        return false;

    QVariantMap reservation = m_reservationService.getSeatedReservationByTable(tableId);

    if (!reservation.isEmpty())
    {
        reservation["status"] = ReservationStatus::Completed;

        if (!m_reservationService.updateReservation(reservation))
            return false;
    }

    return true;
}
