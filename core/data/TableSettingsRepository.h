#ifndef TABLESETTINGSREPOSITORY_H
#define TABLESETTINGSREPOSITORY_H

#include <QString>
#include <QSqlDatabase>
#include "../domain/TableSettings.h"

class TableSettingsRepository
{
public:
    explicit TableSettingsRepository(QSqlDatabase db);

    std::optional<TableSettings> get();
    void save(const TableSettings &tableSettings);

private:
    QSqlDatabase m_db;
};

#endif // TABLESETTINGSREPOSITORY_H
