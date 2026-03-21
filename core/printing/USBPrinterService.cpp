#include "USBPrinterService.h"

#include <QSerialPort>
#include <QSerialPortInfo>
#include <QVariantMap>
#include <QDebug>
#include "./EscPosBuilder.h"

USBPrinterService::USBPrinterService() {}

QStringList USBPrinterService::availablePorts()
{
    QStringList ports;
    for (const QSerialPortInfo &info : QSerialPortInfo::availablePorts())
    {
        ports.append(info.portName());
    }
    return ports;
}

bool USBPrinterService::print(const QString &portName, const QByteArray &data)
{
    if (portName.isEmpty())
    {
        qWarning() << "USB print failed: empty port name";
        return false;
    }

    QSerialPort serial;
    serial.setPortName(portName);

    serial.setBaudRate(QSerialPort::Baud9600);
    serial.setDataBits(QSerialPort::Data8);
    serial.setParity(QSerialPort::NoParity);
    serial.setStopBits(QSerialPort::OneStop);
    serial.setFlowControl(QSerialPort::NoFlowControl);

    if (!serial.open(QIODevice::WriteOnly))
    {
        qWarning() << "Cannot open USB printer on" << portName << ":" << serial.errorString();
        return false;
    }

    qint64 totalWritten = 0;
    const int timeoutMs = 3000;

    while (totalWritten < data.size())
    {
        qint64 written = serial.write(data.constData() + totalWritten,
                                      data.size() - totalWritten);

        if (written == -1)
        {
            qWarning() << "Write error:" << serial.errorString();
            serial.close();
            return false;
        }

        if (!serial.waitForBytesWritten(timeoutMs))
        {
            qWarning() << "Timeout while writing to printer:" << serial.errorString();
            serial.close();
            return false;
        }

        totalWritten += written;
    }

    serial.flush();
    serial.close();

    return true;
}

QVariantList USBPrinterService::getAvailablePrinters()
{
    QVariantList list;

    for (const QSerialPortInfo &info : QSerialPortInfo::availablePorts())
    {
        QVariantMap item;

        QString name = info.description();
        if (name.isEmpty())
            name = info.manufacturer();

        if (name.isEmpty())
            name = "Unknown Printer";

        item["name"] = name;
        item["port"] = info.portName();

        list.append(item);
    }

    return list;
}

bool USBPrinterService::testPrint(const QString &portName)
{
    EscPosBuilder builder;
    builder.initialize();
    builder.setAlignCenter();
    builder.setBold(true);
    builder.addText("TEST PRINT\n");
    builder.setBold(false);
    builder.addText("USB Printer OK\n\n");
    builder.cut("Full Cut");

    return print(portName, builder.data());
}
