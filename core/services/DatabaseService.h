#ifndef DATABASESERVICE_H
#define DATABASESERVICE_H

#include <QObject>
#include "./AppService.h"
#include "../database/DatabaseManager.h"

class DatabaseService : public QObject
{
    Q_OBJECT

public:
    explicit DatabaseService(AppService &appService,
                             DatabaseManager &databaseManager,
                             QObject *parent = nullptr);

    Q_INVOKABLE bool backupDatabase();
    Q_INVOKABLE bool restoreDatabase(const QString &dbFilePath);
    Q_INVOKABLE bool moveDatabase(const QString &destinationFolder);

private:
    AppService &m_appService;
    DatabaseManager &m_databaseManager;

    static bool directoryContainsFilesRecursively(const QString &path);
};

#endif // DATABASESERVICE_H
