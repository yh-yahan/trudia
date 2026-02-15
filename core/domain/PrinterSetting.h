#ifndef PRINTERSETTING_H
#define PRINTERSETTING_H

#include <QString>

class PrinterSetting
{
public:
    int id = -1;
    QString printer_interface;
    std::optional<QString> connection_type;
    std::optional<QString> ip_address;
    std::optional<int> port;
    std::optional<QString> com_port;
    std::optional<int> baud_rate;
    std::optional<QString> parity;
    std::optional<int> data_bits;
    std::optional<int> stop_bits;
    std::optional<QString> flow_control;
    QString paper_width;
    int char_per_line;
    QString cut_mode;
};

#endif // PRINTERSETTING_H
