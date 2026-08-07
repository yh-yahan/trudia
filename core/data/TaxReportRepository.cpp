#include "TaxReportRepository.h"

#include <QSqlQuery>
#include <QSqlError>
#include <QDebug>

TaxReportRepository::TaxReportRepository(QSqlDatabase db)
    : m_db(db) {}

TaxReportSummary TaxReportRepository::getSummary(const QDate &from, const QDate &to) const
{
    TaxReportSummary summary;
    summary.from = from;
    summary.to = to;

    if (!m_db.isOpen()) return summary;

    QSqlQuery q(m_db);
    q.prepare(R"(
        SELECT
            COUNT(*) as transaction_count,
            COALESCE(SUM(subtotal), 0) as subtotal,
            COALESCE(SUM(tax), 0) as tax_collected,
            COALESCE(SUM(discount), 0) as discount,
            COALESCE(SUM(total), 0) as total_sales
        FROM order_sessions
        WHERE status = 'paid'
          AND closed_at IS NOT NULL
          AND date(closed_at) >= :from
          AND date(closed_at) <= :to
    )");

    q.bindValue(":from", from.toString(Qt::ISODate));
    q.bindValue(":to", to.toString(Qt::ISODate));

    if (!q.exec()) {
        qWarning() << "TaxReportRepository::getSummary failed:" << q.lastError();
        return summary;
    }

    if (q.next()) {
        summary.transactionCount = q.value("transaction_count").toInt();
        summary.subtotal = q.value("subtotal").toDouble();
        summary.taxCollected = q.value("tax_collected").toDouble();
        summary.discount = q.value("discount").toDouble();
        summary.totalSales = q.value("total_sales").toDouble();
    }

    QSqlQuery snap(m_db);
    snap.prepare(R"(
        SELECT tax_name, tax_rate, tax_registration_number
        FROM receipt_snapshot
        WHERE order_session_id IN (
            SELECT id FROM order_sessions
            WHERE status = 'paid'
              AND closed_at IS NOT NULL
              AND date(closed_at) >= :from
              AND date(closed_at) <= :to
        )
        ORDER BY created_at DESC
        LIMIT 1
    )");
    snap.bindValue(":from", from.toString(Qt::ISODate));
    snap.bindValue(":to", to.toString(Qt::ISODate));

    if (snap.exec() && snap.next()) {
        summary.taxName = snap.value("tax_name").toString();
        summary.taxRate = snap.value("tax_rate").toInt();
        summary.taxRegistrationNumber = snap.value("tax_registration_number").toString();
    }

    return summary;
}

QVector<TaxReportDailyRow> TaxReportRepository::getDailyBreakdown(const QDate &from, const QDate &to) const
{
    QVector<TaxReportDailyRow> rows;

    if (!m_db.isOpen()) return rows;

    QSqlQuery q(m_db);
    q.prepare(R"(
        SELECT
            date(closed_at) as day,
            COUNT(*) as transaction_count,
            COALESCE(SUM(subtotal), 0) as subtotal,
            COALESCE(SUM(tax), 0) as tax_collected,
            COALESCE(SUM(discount), 0) as discount,
            COALESCE(SUM(total), 0) as total_sales
        FROM order_sessions
        WHERE status = 'paid'
          AND closed_at IS NOT NULL
          AND date(closed_at) >= :from
          AND date(closed_at) <= :to
        GROUP BY date(closed_at)
        ORDER BY day ASC
    )");

    q.bindValue(":from", from.toString(Qt::ISODate));
    q.bindValue(":to", to.toString(Qt::ISODate));

    if (!q.exec()) {
        qWarning() << "TaxReportRepository::getDailyBreakdown failed:" << q.lastError();
        return rows;
    }

    while (q.next()) {
        TaxReportDailyRow row;
        row.date = QDate::fromString(q.value("day").toString(), Qt::ISODate);
        row.transactionCount = q.value("transaction_count").toInt();
        row.subtotal = q.value("subtotal").toDouble();
        row.taxCollected = q.value("tax_collected").toDouble();
        row.discount = q.value("discount").toDouble();
        row.totalSales = q.value("total_sales").toDouble();
        rows.append(row);
    }

    return rows;
}

QVector<TaxReportSessionRow> TaxReportRepository::getSessions(const QDate &from, const QDate &to) const
{
    QVector<TaxReportSessionRow> rows;

    if (!m_db.isOpen()) return rows;

    QSqlQuery q(m_db);
    q.prepare(R"(
        SELECT
            os.id,
            os.receipt_number,
            os.order_type,
            t.table_name as table_name,
            os.subtotal,
            os.tax,
            os.discount,
            os.total,
            os.closed_at
        FROM order_sessions os
        LEFT JOIN tables t ON t.id = os.table_id
        WHERE os.status = 'paid'
          AND os.closed_at IS NOT NULL
          AND date(os.closed_at) >= :from
          AND date(os.closed_at) <= :to
        ORDER BY os.closed_at DESC
    )");

    q.bindValue(":from", from.toString(Qt::ISODate));
    q.bindValue(":to", to.toString(Qt::ISODate));

    if (!q.exec()) {
        qWarning() << "TaxReportRepository::getSessions failed:" << q.lastError();
        return rows;
    }

    while (q.next()) {
        TaxReportSessionRow row;
        row.sessionId = q.value("id").toInt();
        row.receiptNumber = q.value("receipt_number").toString();
        row.orderType = q.value("order_type").toString();
        row.tableName = q.value("table_name").toString();
        row.subtotal = q.value("subtotal").toDouble();
        row.tax = q.value("tax").toDouble();
        row.discount = q.value("discount").toDouble();
        row.total = q.value("total").toDouble();
        row.closedAt = QDateTime::fromString(q.value("closed_at").toString(), Qt::ISODate);
        rows.append(row);
    }

    return rows;
}
