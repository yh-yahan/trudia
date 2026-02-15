#ifndef PRINTERSETTINGREPOSITORY_H
#define PRINTERSETTINGREPOSITORY_H

#include <QString>
#include <QSqlDatabase>
#include "../domain/PrinterSetting.h"

class PrinterSettingRepository
{
public:
    explicit PrinterSettingRepository(QSqlDatabase db);

    std::optional<PrinterSetting> get();
    void save(const PrinterSetting &setting);

private:
    QSqlDatabase m_db;
};

#endif // PRINTERSETTINGREPOSITORY_H
