#include "AnalyticsService.h"

AnalyticsService::AnalyticsService(AnalyticsRepository &analyticsRepo)
    : m_analyticsRepo(analyticsRepo) {}

QVariantMap AnalyticsService::getSnapshot()
{
    QVariantMap snapshot;

    snapshot["revenueToday"] = m_analyticsRepo.revenueToday() / 100.0;
    snapshot["ordersToday"] = m_analyticsRepo.ordersCountToday();
    snapshot["averageOrder"] = m_analyticsRepo.averageOrderToday() / 100.0;
    snapshot["itemsSold"] = m_analyticsRepo.itemsSoldToday();

    // top items
    QVariantList topItemsList;
    for (const ItemCount &item : m_analyticsRepo.topItemsToday()) {
        QVariantMap itemMap;
        itemMap["name"] = item.name;
        itemMap["count"] = item.count;
        topItemsList.append(itemMap);
    }
    snapshot["topItems"] = topItemsList;

    // revenue by hour
    QVariantList revenueByHourList;
    for (const RevenueHour &rh : m_analyticsRepo.revenueByHourToday()) {
        QVariantMap rhMap;

        QString hourRange;
        if (rh.hour == 0) {
            hourRange = QString("12am-1am");
        } else if (rh.hour > 0 && rh.hour < 12) {
            hourRange = QString("%1am-%2am").arg(rh.hour).arg(rh.hour + 1);
        } else if (rh.hour == 12) {
            hourRange = QString("12pm-1pm");
        } else {
            hourRange = QString("%1pm-%2pm").arg(rh.hour - 12).arg(rh.hour + 1 - 12);
        }

        rhMap["hour"] = hourRange;
        rhMap["amount"] = rh.amount / 100.0;
        revenueByHourList.append(rhMap);
    }

    snapshot["revenueByHour"] = revenueByHourList;

    // revenue last seven days
    QVariantList last7DaysList;
    for (const RevenueDay &rd : m_analyticsRepo.revenueLastSevenDays()) {
        QVariantMap rdMap;
        rdMap["day"] = rd.day;
        rdMap["amount"] = rd.amount / 100.0;
        last7DaysList.append(rdMap);
    }
    snapshot["last7Days"] = last7DaysList;

    return snapshot;
}
