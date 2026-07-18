#include "PrinterRepository.h"

#include <QSqlQuery>
#include <QSqlError>
#include <QVariant>
#include "../logging/LoggingCategories.h"

PrinterRepository::PrinterRepository(QSqlDatabase db)
    : m_db(db) {}

std::vector<Printer> PrinterRepository::getAll()
{
    std::vector<Printer> printers;

    QSqlQuery query(m_db);

    query.prepare(R"(
        SELECT
            id,
            system_name,
            role,
            paper_width,
            cut_mode
        FROM printers
    )");

    if (!query.exec()) {
        qCWarning(logDatabase) << "Failed to get all printers:" << query.lastError().text();
        return printers;
    }

    while (query.next()) {
        Printer printer;
        printer.id = query.value("id").toInt();
        printer.system_name = query.value("system_name").toString();
        printer.role = query.value("role").toString();
        printer.paper_width = query.value("paper_width").toInt();
        printer.cut_mode = query.value("cut_mode").toString();

        printers.push_back(printer);
    }

    return printers;
}

std::optional<Printer> PrinterRepository::get(int printerId)
{
    QSqlQuery query(m_db);

    query.prepare(R"(
        SELECT
            id,
            system_name,
            role,
            paper_width,
            cut_mode
        FROM printers
        WHERE id = ?
    )");

    query.addBindValue(printerId);

    if (!query.exec()) {
        qCWarning(logDatabase) << "Failed to get printer:" << query.lastError().text();
        return std::nullopt;
    }

    if (!query.next())
        return std::nullopt;

    Printer printer;
    printer.id = query.value("id").toInt();
    printer.system_name = query.value("system_name").toString();
    printer.role = query.value("role").toString();
    printer.paper_width = query.value("paper_width").toInt();
    printer.cut_mode = query.value("cut_mode").toString();

    return printer;
}

void PrinterRepository::add(const Printer &printer)
{
    QSqlQuery query(m_db);

    query.prepare(R"(
        INSERT INTO printers (
            system_name,
            role,
            paper_width,
            cut_mode
        )
        VALUES (?, ?, ?, ?)
    )");

    query.addBindValue(printer.system_name);
    query.addBindValue(printer.role);
    query.addBindValue(printer.paper_width);
    query.addBindValue(printer.cut_mode);

    if (!query.exec()) {
        qCWarning(logDatabase) << "Failed to insert printer:" << query.lastError().text();
    }
}

void PrinterRepository::update(const Printer &printer)
{
    QSqlQuery query(m_db);

    query.prepare(R"(
        UPDATE printers
        SET
            system_name = ?,
            role = ?,
            paper_width = ?,
            cut_mode = ?,
            updated_at = CURRENT_TIMESTAMP
        WHERE id = ?
    )");

    query.addBindValue(printer.system_name);
    query.addBindValue(printer.role);
    query.addBindValue(printer.paper_width);
    query.addBindValue(printer.cut_mode);
    query.addBindValue(printer.id);

    if (!query.exec()) {
        qCWarning(logDatabase) << "Failed to update printer:" << query.lastError().text();
    }
}

void PrinterRepository::remove(const Printer &printer)
{
    QSqlQuery query(m_db);

    query.prepare(R"(
        DELETE FROM printers
        WHERE id = ?
    )");

    query.addBindValue(printer.id);

    if (!query.exec()) {
        qCWarning(logDatabase) << "Failed to delete printer:" << query.lastError().text();
    }
}
