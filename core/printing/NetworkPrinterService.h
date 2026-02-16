#ifndef NETWORKPRINTERSERVICE_H
#define NETWORKPRINTERSERVICE_H

#include <QString>
#include <QByteArray>

class NetworkPrinterService
{
public:
    bool print(const QString &ip, quint16 port, const QByteArray &data);
};

#endif // NETWORKPRINTERSERVICE_H
