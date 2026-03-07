#include "AnalyticsRepository.h"

#include <QSqlQuery>
#include <QSqlError>
#include <QVariant>
#include <QDebug>
#include <QDate>
#include <QMap>

AnalyticsRepository::AnalyticsRepository(QSqlDatabase db): m_db(db) {}

double AnalyticsRepository::revenueToday()
{
    double revenue = 0.0;

    QSqlQuery query(m_db);
    query.prepare(R"(
        SELECT SUM(total)
        FROM order_sessions
        WHERE status = 'paid'
          AND DATE(closed_at) = DATE('now')
    )");

    if (!query.exec()) {
        qWarning() << "AnalyticsRepository::revenueToday failed:" << query.lastError().text();
        return 0.0;
    }

    if (query.next() && !query.value(0).isNull()) {
        revenue = query.value(0).toDouble();
    }

    return revenue;
}

int AnalyticsRepository::ordersCountToday()
{
    int count = 0;

    QSqlQuery query(m_db);
    query.prepare(R"(
        SELECT COUNT(*)
        FROM order_sessions
        WHERE DATE(opened_at) = DATE('now')
    )");

    if (!query.exec()) {
        qWarning() << "AnalyticsRepository::ordersCountToday failed:" << query.lastError().text();
        return 0;
    }

    if (query.next() && !query.value(0).isNull()) {
        count = query.value(0).toInt();
    }

    return count;
}

double AnalyticsRepository::averageOrderToday()
{
    double average = 0.0;

    QSqlQuery query(m_db);
    query.prepare(R"(
        SELECT AVG(total)
        FROM order_sessions
        WHERE DATE(opened_at) = DATE('now')
    )");

    if (!query.exec()) {
        qWarning() << "AnalyticsRepository::averageOrderToday failed:" << query.lastError().text();
        return 0.0;
    }

    if (query.next() && !query.value(0).isNull()) {
        average = query.value(0).toDouble();
    }

    return average;
}

int AnalyticsRepository::itemsSoldToday()
{
    int totalItems = 0;

    QSqlQuery query(m_db);
    query.prepare(R"(
        SELECT SUM(oi.quantity)
        FROM order_items oi
        JOIN orders o ON oi.order_id = o.id
        JOIN order_sessions os ON o.order_session_id = os.id
        WHERE DATE(os.opened_at) = DATE('now')
    )");

    if (!query.exec()) {
        qWarning() << "AnalyticsRepository::itemsSoldToday failed:" << query.lastError().text();
        return 0;
    }

    if (query.next() && !query.value(0).isNull()) {
        totalItems = query.value(0).toInt();
    }

    return totalItems;
}

std::vector<ItemCount> AnalyticsRepository::topItemsToday()
{
    std::vector<ItemCount> topItems;

    QSqlQuery query(m_db);
    query.prepare(R"(
        SELECT oi.item_name, SUM(oi.quantity) AS total_quantity
        FROM order_items oi
        JOIN orders o ON oi.order_id = o.id
        JOIN order_sessions os ON o.order_session_id = os.id
        WHERE DATE(os.opened_at) = DATE('now')
        GROUP BY oi.item_name
        ORDER BY total_quantity DESC
        LIMIT 5
    )");

    if (!query.exec()) {
        qWarning() << "AnalyticsRepository::topItemsToday failed:" << query.lastError().text();
        return topItems;
    }

    while (query.next()) {
        ItemCount item;
        item.name = query.value("item_name").toString();
        item.count = query.value("total_quantity").toInt();
        topItems.push_back(item);
    }

    return topItems;
}

std::vector<RevenueHour> AnalyticsRepository::revenueByHourToday()
{
    std::vector<RevenueHour> revenueByHour;

    QSqlQuery query(m_db);
    query.prepare(R"(
        SELECT STRFTIME('%H', opened_at) AS hour, SUM(total) AS amount
        FROM order_sessions
        WHERE DATE(opened_at) = DATE('now')
        GROUP BY hour
        ORDER BY hour ASC
    )");

    if (!query.exec()) {
        qWarning() << "AnalyticsRepository::revenueByHourToday failed:" << query.lastError().text();
        return revenueByHour;
    }

    while (query.next()) {
        RevenueHour rh;
        int hourUTC = query.value("hour").toInt();
        double amount = query.value("amount").toDouble();

        int hourMYT = (hourUTC + 8) % 24;

        rh.hour = hourMYT;
        rh.amount = amount;
        revenueByHour.push_back(rh);
    }

    return revenueByHour;
}

std::vector<RevenueDay> AnalyticsRepository::revenueLastSevenDays()
{
    std::vector<RevenueDay> lastSevenDays;

    QSqlQuery query(m_db);
    query.prepare(R"(
        SELECT DATE(opened_at) AS day, SUM(total) AS amount
        FROM order_sessions
        WHERE DATE(opened_at) >= DATE('now', '-6 days')
        GROUP BY day
        ORDER BY day ASC
    )");

    QMap<QString, double> revenueMap;

    if (!query.exec()) {
        qWarning() << "AnalyticsRepository::revenueLastSevenDays failed:" << query.lastError().text();
    } else {
        while (query.next()) {
            QString day = query.value("day").toString();
            double amount = query.value("amount").toDouble();
            revenueMap[day] = amount;
        }
    }

    QDate today = QDate::currentDate();
    for (int i = 6; i >= 0; --i) {
        QDate date = today.addDays(-i);
        QString dayStr = date.toString("yyyy-MM-dd");

        RevenueDay rd;
        rd.day = dayStr;
        rd.amount = revenueMap.value(dayStr, 0.0);
        lastSevenDays.push_back(rd);
    }

    return lastSevenDays;
}
