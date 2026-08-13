#ifndef DATABASEMANAGER_H
#define DATABASEMANAGER_H

#include <QtSql>

class DatabaseManager
{
public:
    static bool initialize(const QString& dbPath);
    static bool runMigrations();

    bool openExisting(const QString &dbPath);

    static bool canOpen(const QString& dbPath);

    static bool isOpen();
    static bool checkpoint();
    static void close();

    bool beginTransaction();
    bool commit();
    bool rollback();

    static QSqlDatabase db();
};

#endif // DATABASEMANAGER_H
