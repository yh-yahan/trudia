#ifndef BETASERVICE_H
#define BETASERVICE_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>

class BetaService : public QObject
{
    Q_OBJECT

public:
    explicit BetaService(QObject *parent = nullptr);

    Q_INVOKABLE void submitBetaInfo(const QString &name, const QString &email);

signals:
    void submitFinished(bool success);

private:
    QNetworkAccessManager m_manager;
};

#endif // BETASERVICE_H
