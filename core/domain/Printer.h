#ifndef PRINTER_H
#define PRINTER_H

#include <QString>

struct Printer {
    int id = -1;
    QString system_name; // windows printer name
    QString role;
    int paper_width;
    QString cut_mode;
};

#endif // PRINTER_H
