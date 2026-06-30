#ifndef APPSTATEREPOSITORY_H
#define APPSTATEREPOSITORY_H

#include <vector>
#include <QSqlDatabase>
#include "../domain/AppState.h"

class AppStateRepository
{
public:
    explicit AppStateRepository(QSqlDatabase db);

    std::optional<QString> get(const QString &key) const;
    bool set(const AppState &appState);
    bool exists(const QString &key) const;
    bool remove(const QString &key);

private:
    QSqlDatabase m_db;
};

#endif // APPSTATEREPOSITORY_H
