#ifndef DATABASEMANAGER_H
#define DATABASEMANAGER_H
#include <QtSql>

class DatabaseManager
{
public:
    static bool initialize();
    static QSqlDatabase db();

private:
    static bool runMigrations();
};

#endif // DATABASEMANAGER_H
