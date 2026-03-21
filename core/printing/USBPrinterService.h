#ifndef USBPRINTERSERVICE_H
#define USBPRINTERSERVICE_H

#include <QObject>
#include <QString>
#include <QByteArray>
#include <QVariant>

class USBPrinterService : public QObject
{
    Q_OBJECT

public:
    explicit USBPrinterService();

    Q_INVOKABLE bool print(const QString &portName, const QByteArray &data);
    Q_INVOKABLE static QStringList availablePorts();
    Q_INVOKABLE QVariantList getAvailablePrinters();
    Q_INVOKABLE bool testPrint(const QString &portName);
};

#endif // USBPRINTERSERVICE_H
