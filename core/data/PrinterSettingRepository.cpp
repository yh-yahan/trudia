#include "PrinterSettingRepository.h"

#include <QSqlQuery>
#include <QSqlError>
#include <QVariant>
#include <QDebug>

PrinterSettingRepository::PrinterSettingRepository(QSqlDatabase db): m_db(db) {}

std::optional<PrinterSetting> PrinterSettingRepository::get()
{
    QSqlQuery query(m_db);
    query.prepare("SELECT id, printer_interface, connection_type, ip_address, port, "
                  "com_port, baud_rate, parity, data_bits, stop_bits, flow_control, "
                  "paper_width, char_per_line, cut_mode "
                  "FROM printers "
                  "ORDER BY id LIMIT 1");

    if (!query.exec()) {
        qDebug() << "Failed to fetch printer setting:" << query.lastError().text();
        return std::nullopt;
    }

    if (!query.next()) {
        return std::nullopt;
    }

    PrinterSetting setting;

    setting.id = query.value("id").toInt();
    setting.printer_interface = query.value("printer_interface").toString();

    if (!query.value("connection_type").isNull())
        setting.connection_type = query.value("connection_type").toString();

    if (!query.value("ip_address").isNull())
        setting.ip_address = query.value("ip_address").toString();

    if (!query.value("port").isNull())
        setting.port = query.value("port").toInt();

    if (!query.value("com_port").isNull())
        setting.com_port = query.value("com_port").toString();

    if (!query.value("baud_rate").isNull())
        setting.baud_rate = query.value("baud_rate").toInt();

    if (!query.value("parity").isNull())
        setting.parity = query.value("parity").toString();

    if (!query.value("data_bits").isNull())
        setting.data_bits = query.value("data_bits").toInt();

    if (!query.value("stop_bits").isNull())
        setting.stop_bits = query.value("stop_bits").toInt();

    if (!query.value("flow_control").isNull())
        setting.flow_control = query.value("flow_control").toString();

    setting.paper_width = query.value("paper_width").toString();
    setting.char_per_line = query.value("char_per_line").toInt();
    setting.cut_mode = query.value("cut_mode").toString();

    return setting;
}

void PrinterSettingRepository::save(const PrinterSetting &setting)
{
    auto existing = get();

    QSqlQuery query(m_db);

    if (!existing.has_value()) {
        query.prepare("INSERT INTO printers ("
                      "printer_interface, connection_type, ip_address, port, "
                      "com_port, baud_rate, parity, data_bits, stop_bits, flow_control, "
                      "paper_width, char_per_line, cut_mode"
                      ") VALUES ("
                      ":printer_interface, :connection_type, :ip_address, :port, "
                      ":com_port, :baud_rate, :parity, :data_bits, :stop_bits, :flow_control, "
                      ":paper_width, :char_per_line, :cut_mode"
                      ")");
    } else {
        query.prepare("UPDATE printers SET "
                      "printer_interface = :printer_interface, "
                      "connection_type = :connection_type, "
                      "ip_address = :ip_address, "
                      "port = :port, "
                      "com_port = :com_port, "
                      "baud_rate = :baud_rate, "
                      "parity = :parity, "
                      "data_bits = :data_bits, "
                      "stop_bits = :stop_bits, "
                      "flow_control = :flow_control, "
                      "paper_width = :paper_width, "
                      "char_per_line = :char_per_line, "
                      "cut_mode = :cut_mode "
                      "WHERE id = :id");

        query.bindValue(":id", existing->id);
    }

    query.bindValue(":printer_interface", setting.printer_interface);

    query.bindValue(":connection_type",
                    setting.connection_type
                        ? QVariant(*setting.connection_type)
                        : QVariant());

    query.bindValue(":ip_address",
                    setting.ip_address
                        ? QVariant(*setting.ip_address)
                        : QVariant());

    query.bindValue(":port",
                    setting.port
                        ? QVariant(*setting.port)
                        : QVariant());

    query.bindValue(":com_port",
                    setting.com_port
                        ? QVariant(*setting.com_port)
                        : QVariant());

    query.bindValue(":baud_rate",
                    setting.baud_rate
                        ? QVariant(*setting.baud_rate)
                        : QVariant());

    query.bindValue(":parity",
                    setting.parity
                        ? QVariant(*setting.parity)
                        : QVariant());

    query.bindValue(":data_bits",
                    setting.data_bits
                        ? QVariant(*setting.data_bits)
                        : QVariant());

    query.bindValue(":stop_bits",
                    setting.stop_bits
                        ? QVariant(*setting.stop_bits)
                        : QVariant());

    query.bindValue(":flow_control",
                    setting.flow_control
                        ? QVariant(*setting.flow_control)
                        : QVariant());

    query.bindValue(":paper_width", setting.paper_width);
    query.bindValue(":char_per_line", setting.char_per_line);
    query.bindValue(":cut_mode", setting.cut_mode);

    qDebug() << "Expected placeholders:" << query.boundValues();

    if (!query.exec()) {
        qDebug() << "Failed to save printer setting:" << query.lastError().text();
    }

    qDebug() << "Query:" << query.lastQuery();
}
