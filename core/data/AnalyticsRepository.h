#ifndef ANALYTICSREPOSITORY_H
#define ANALYTICSREPOSITORY_H

#include <QString>
#include <QSqlDatabase>

struct ItemCount {
    QString name;
    int count;
};

struct RevenueHour {
    int hour;
    double amount;
};

struct RevenueDay {
    QString day;
    double amount;
};

class AnalyticsRepository
{
public:
    explicit AnalyticsRepository(QSqlDatabase db);

    double revenueToday();
    int ordersCountToday();
    double averageOrderToday();
    int itemsSoldToday();
    std::vector<ItemCount> topItemsToday();
    std::vector<RevenueHour> revenueByHourToday();
    std::vector<RevenueDay> revenueLastSevenDays();

private:
    QSqlDatabase m_db;
};

#endif // ANALYTICSREPOSITORY_H
