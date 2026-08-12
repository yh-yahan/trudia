#ifndef APPSERVICE_H
#define APPSERVICE_H

#include <QObject>
#include <QString>

class AppService : public QObject
{
    Q_OBJECT

public:
    explicit AppService(QObject *parent = nullptr);

    enum AppState {
        NeedsSetup,
        FileNotFoundNeedsSetup,
        UnableToOpenNeedsSetup,
        NeedsAdminSetup,
        Ready
    };
    Q_ENUM(AppState)

    Q_INVOKABLE AppState determineState() const;

    Q_INVOKABLE QString databasePath() const;
    Q_INVOKABLE void setDatabasePath(const QString &path);
    Q_INVOKABLE bool hasDatabasePath() const;

private:
    QString m_dbPathKey = "database/path";

    bool hasAdminUser() const;
};

#endif // APPSERVICE_H
