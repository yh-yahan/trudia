#ifndef TAXSETTINGSREPOSITORY_H
#define TAXSETTINGSREPOSITORY_H

#include <QString>
#include <QSqlDatabase>
#include "../domain/TaxSettings.h"

class TaxSettingsRepository
{
public:
    explicit TaxSettingsRepository(QSqlDatabase db);

    std::optional<TaxSettings> get();
    void save(const TaxSettings &taxSettings);

private:
    QSqlDatabase m_db;
};

#endif // TAXSETTINGSREPOSITORY_H
