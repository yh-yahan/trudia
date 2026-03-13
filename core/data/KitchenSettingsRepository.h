#ifndef KITCHENSETTINGSREPOSITORY_H
#define KITCHENSETTINGSREPOSITORY_H

#include <QString>
#include <QSqlDatabase>
#include "../domain/KitchenSettings.h"

class KitchenSettingsRepository
{
public:
    explicit KitchenSettingsRepository(QSqlDatabase db);

    std::optional<KitchenSettings> get();
    void save(const KitchenSettings &kitchenSettings);

private:
    QSqlDatabase m_db;
};

#endif // KITCHENSETTINGSREPOSITORY_H
