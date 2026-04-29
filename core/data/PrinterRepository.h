#ifndef PRINTERREPOSITORY_H
#define PRINTERREPOSITORY_H

#include <QString>
#include <QSqlDatabase>
#include "../domain/Printer.h"

class PrinterRepository
{
public:
    explicit PrinterRepository(QSqlDatabase db);

    std::vector<Printer> getAll();
    std::optional<Printer> get(int printerId);
    void add(const Printer &printer);
    void update(const Printer &printer);
    void remove(const Printer &printer);

private:
    QSqlDatabase m_db;
};

#endif // PRINTERREPOSITORY_H
