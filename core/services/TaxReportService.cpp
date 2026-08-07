#include "TaxReportService.h"

#include <QDate>

TaxReportService::TaxReportService(TaxReportRepository &repository, QObject *parent)
    : QObject(parent), 
      m_repo(repository) {}

QVariantMap TaxReportService::getSummary(const QDate &from, const QDate &to) const
{
    return summaryToVariant(m_repo.getSummary(from, to));
}

QVariantList TaxReportService::getDailyBreakdown(const QDate &from, const QDate &to) const
{
    QVariantList list;
    const auto rows = m_repo.getDailyBreakdown(from, to);
    for (const auto& row : rows) {
        list.append(dailyRowToVariant(row));
    }
    return list;
}

QVariantList TaxReportService::getSessions(const QDate &from, const QDate &to) const
{
    QVariantList list;
    const auto rows = m_repo.getSessions(from, to);
    for (const auto& row : rows) {
        list.append(sessionRowToVariant(row));
    }
    return list;
}

QVariantMap TaxReportService::getTodaySummary() const
{
    const QDate today = QDate::currentDate();
    return getSummary(today, today);
}

QVariantMap TaxReportService::getYesterdaySummary() const
{
    const QDate yesterday = QDate::currentDate().addDays(-1);
    return getSummary(yesterday, yesterday);
}

QVariantMap TaxReportService::getThisWeekSummary() const
{
    const QDate today = QDate::currentDate();
    // Assuming week starts on Monday
    const QDate start = today.addDays(-(today.dayOfWeek() - 1));
    return getSummary(start, today);
}

QVariantMap TaxReportService::getThisMonthSummary() const
{
    const QDate today = QDate::currentDate();
    const QDate start(today.year(), today.month(), 1);
    return getSummary(start, today);
}

QVariantMap TaxReportService::getLastMonthSummary() const
{
    const QDate today = QDate::currentDate();
    const QDate firstOfThisMonth(today.year(), today.month(), 1);
    const QDate lastMonthEnd = firstOfThisMonth.addDays(-1);
    const QDate lastMonthStart(lastMonthEnd.year(), lastMonthEnd.month(), 1);
    return getSummary(lastMonthStart, lastMonthEnd);
}

QVariantMap TaxReportService::summaryToVariant(const TaxReportSummary &s) const
{
    return {
        { "from", s.from.toString(Qt::ISODate) },
        { "to", s.to.toString(Qt::ISODate) },
        { "transactionCount", s.transactionCount },
        { "subtotal", s.subtotal },
        { "taxCollected", s.taxCollected },
        { "discount", s.discount },
        { "totalSales", s.totalSales },
        { "taxName", s.taxName },
        { "taxRate", s.taxRate },
        { "taxRegistrationNumber", s.taxRegistrationNumber }
    };
}

QVariantMap TaxReportService::dailyRowToVariant(const TaxReportDailyRow &row) const
{
    return {
        { "date", row.date.toString(Qt::ISODate) },
        { "transactionCount", row.transactionCount },
        { "subtotal", row.subtotal },
        { "taxCollected", row.taxCollected },
        { "discount", row.discount },
        { "totalSales", row.totalSales }
    };
}

QVariantMap TaxReportService::sessionRowToVariant(const TaxReportSessionRow &row) const
{
    return {
        { "sessionId", row.sessionId },
        { "receiptNumber", row.receiptNumber },
        { "orderType", row.orderType },
        { "tableName", row.tableName },
        { "subtotal", row.subtotal },
        { "tax", row.tax },
        { "discount", row.discount },
        { "total", row.total },
        { "closedAt", row.closedAt.toString(Qt::ISODate) }
    };
}
