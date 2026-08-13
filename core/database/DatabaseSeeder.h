#ifndef DATABASESEEDER_H
#define DATABASESEEDER_H

#include <QtSql>

class DatabaseSeeder
{
public:
    explicit DatabaseSeeder(QSqlDatabase db);

    bool seed();

private:
    QSqlDatabase m_db;

    bool seedSettings();
    bool seedAppState();
};

#endif // DATABASESEEDER_H
