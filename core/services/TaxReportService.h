#ifndef TAXREPORTSERVICE_H
#define TAXREPORTSERVICE_H

#include <QObject>
#include <QVariantMap>
#include <QVariantList>
#include <QDate>
#include "../data/TaxReportRepository.h"

class TaxReportService : public QObject
{
    Q_OBJECT

public:
    explicit TaxReportService(TaxReportRepository& repository, QObject* parent = nullptr);

    Q_INVOKABLE QVariantMap getSummary(const QDate &from, const QDate &to) const;
    Q_INVOKABLE QVariantList getDailyBreakdown(const QDate &from, const QDate &to) const;
    Q_INVOKABLE QVariantList getSessions(const QDate &from, const QDate &to) const;

    Q_INVOKABLE QVariantMap getTodaySummary() const;
    Q_INVOKABLE QVariantMap getYesterdaySummary() const;
    Q_INVOKABLE QVariantMap getThisWeekSummary() const;
    Q_INVOKABLE QVariantMap getThisMonthSummary() const;
    Q_INVOKABLE QVariantMap getLastMonthSummary() const;

private:
    TaxReportRepository& m_repo;

    QVariantMap summaryToVariant(const TaxReportSummary& s) const;
    QVariantMap dailyRowToVariant(const TaxReportDailyRow& row) const;
    QVariantMap sessionRowToVariant(const TaxReportSessionRow& row) const;
};

#endif // TAXREPORTSERVICE_H
