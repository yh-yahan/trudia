#include "NetworkPrinterService.h"

#include <QTcpSocket>
#include <QDebug>

bool NetworkPrinterService::print(const QString &ip, quint16 port, const QByteArray &data)
{
    QTcpSocket socket;

    socket.connectToHost(ip, port);

    if (!socket.waitForConnected(3000)) {
        qWarning() << "Printer connection failed:" << socket.errorString();
        return false;
    }

    socket.write(data);

    if (!socket.waitForBytesWritten(3000)) {
        qWarning() << "Failed to write to printer:" << socket.errorString();
        socket.disconnectFromHost();
        return false;
    }

    socket.flush();
    socket.disconnectFromHost();

    return true;
}
