#ifndef TAXREPORTREPOSITORY_H
#define TAXREPORTREPOSITORY_H

#include <QSqlDatabase>
#include <QVector>
#include <QDate>

struct TaxReportSummary {
    QDate from;
    QDate to;

    int transactionCount = 0;
    double subtotal = 0.0;
    double taxCollected = 0.0;
    double discount = 0.0;
    double totalSales = 0.0;

    // from the most recent snapshot in the period (or empty if none)
    QString taxName;
    int taxRate = 0; // scaled (100 = 1%)
    QString taxRegistrationNumber;
};

struct TaxReportDailyRow {
    QDate date;
    int transactionCount = 0;
    double subtotal = 0.0;
    double taxCollected = 0.0;
    double discount = 0.0;
    double totalSales = 0.0;
};

struct TaxReportSessionRow {
    int sessionId = 0;
    QString receiptNumber;
    QString orderType;
    QString tableName;
    double subtotal = 0.0;
    double tax = 0.0;
    double discount = 0.0;
    double total = 0.0;
    QDateTime closedAt;
};

class TaxReportRepository
{
public:
    explicit TaxReportRepository(QSqlDatabase db);

    TaxReportSummary getSummary(const QDate &from, const QDate &to) const;
    QVector<TaxReportDailyRow> getDailyBreakdown(const QDate &from, const QDate &to) const;
    QVector<TaxReportSessionRow> getSessions(const QDate &from, const QDate &to) const;

private:
    QSqlDatabase m_db;
};

#endif // TAXREPORTREPOSITORY_H
