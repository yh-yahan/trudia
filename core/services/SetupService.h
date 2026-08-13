#ifndef SETUPSERVICE_H
#define SETUPSERVICE_H

#include <QObject>
#include <QString>
#include "AppService.h"
#include "../database/DatabaseManager.h"

class SetupService : public QObject
{
    Q_OBJECT

public:
    explicit SetupService(AppService &appService,
                          DatabaseManager &databaseManager,
                          QObject *parent = nullptr);

    enum SetupResult {
        Success,
        DatabaseExists,
        InvalidPath,
        InitializationFailed
    };
    Q_ENUM(SetupResult)

    Q_INVOKABLE SetupResult initializeApp(const QString &dbPath);

    Q_INVOKABLE void restartApp();

private:
    AppService &m_appService;
    DatabaseManager &m_databaseManager;
};

#endif // SETUPSERVICE_H
