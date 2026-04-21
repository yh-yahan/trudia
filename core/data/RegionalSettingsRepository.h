#ifndef REGIONALSETTINGSREPOSITORY_H
#define REGIONALSETTINGSREPOSITORY_H

#include <QString>
#include <QSqlDatabase>
#include "../domain/RegionalSettings.h"

class RegionalSettingsRepository
{
public:
    explicit RegionalSettingsRepository(QSqlDatabase db);

    std::optional<RegionalSettings> get();
    void save(const RegionalSettings &setting);

private:
    QSqlDatabase m_db;
};

#endif // REGIONALSETTINGSREPOSITORY_H
