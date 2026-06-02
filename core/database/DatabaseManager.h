#ifndef DATABASEMANAGER_H
#define DATABASEMANAGER_H
#include <QtSql>

class DatabaseManager
{
public:
    static bool initialize(const QString& dbPath);
    static bool runMigrations();

    static bool canOpen(const QString& dbPath);

    static bool isOpen();
    static bool checkpoint();
    static void close();

    static QSqlDatabase db();
};

#endif // DATABASEMANAGER_H
