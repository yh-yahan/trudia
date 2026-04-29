#ifndef WINDOWSPRINTERSERVICE_H
#define WINDOWSPRINTERSERVICE_H

#include <QObject>
#include <QString>
#include <QByteArray>
#include <QVariant>

class WindowsPrinterService : public QObject
{
    Q_OBJECT

public:
    explicit WindowsPrinterService();

    Q_INVOKABLE bool print(const QString &portName, const QByteArray &data);
    Q_INVOKABLE QVariantList getAvailablePrinters();
    Q_INVOKABLE bool testPrint(const QString &printerName);
};

#endif // WINDOWSPRINTERSERVICE_H
