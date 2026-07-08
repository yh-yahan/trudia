#ifndef MEMBERSHIPSETTINGSREPOSITORY_H
#define MEMBERSHIPSETTINGSREPOSITORY_H

#include <QString>
#include <QSqlDatabase>
#include "../domain/MembershipSettings.h"

class MembershipSettingsRepository
{
public:
    explicit MembershipSettingsRepository(QSqlDatabase db);
    virtual ~MembershipSettingsRepository() = default;

    virtual std::optional<MembershipSettings> get();
    void save(const MembershipSettings &membershipSettings);

private:
    QSqlDatabase m_db;
};

#endif // MEMBERSHIPSETTINGSREPOSITORY_H
