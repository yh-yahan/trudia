#include "USBPrinterService.h"

#include <QVariantMap>
#include <QDebug>
#ifdef Q_OS_WIN
#include <windows.h>
#endif
#include "./EscPosBuilder.h"

USBPrinterService::USBPrinterService() {}

bool USBPrinterService::print(const QString &printerName, const QByteArray &data)
{
    #ifdef Q_OS_WIN
    if (printerName.isEmpty())
    {
        qWarning() << "Print failed: empty printer name";
        return false;
    }

    HANDLE hPrinter;

    if (!OpenPrinterW((LPWSTR)printerName.utf16(), &hPrinter, NULL))
    {
        qWarning() << "Failed to open printer:" << printerName;
        return false;
    }

    DOC_INFO_1W docInfo;
    docInfo.pDocName = (LPWSTR)L"Trudia Receipt/Kitchen Ticket";
    docInfo.pOutputFile = NULL;
    docInfo.pDatatype = (LPWSTR)L"RAW";

    if (StartDocPrinterW(hPrinter, 1, (LPBYTE)&docInfo) == 0)
    {
        qWarning() << "StartDocPrinter failed";
        ClosePrinter(hPrinter);
        return false;
    }

    if (!StartPagePrinter(hPrinter))
    {
        qWarning() << "StartPagePrinter failed";
        EndDocPrinter(hPrinter);
        ClosePrinter(hPrinter);
        return false;
    }

    DWORD bytesWritten = 0;
    BOOL success = WritePrinter(
        hPrinter,
        (LPVOID)data.constData(),
        data.size(),
        &bytesWritten
    );

    if (!success || bytesWritten != (DWORD)data.size())
    {
        qWarning() << "WritePrinter failed";
    }

    EndPagePrinter(hPrinter);
    EndDocPrinter(hPrinter);
    ClosePrinter(hPrinter);

    return success;
#else
    Q_UNUSED(printerName)
    Q_UNUSED(data)
    qWarning() << "Windows printing only supported on Windows";
    return false;
#endif
}

QVariantList USBPrinterService::getAvailablePrinters()
{
    QVariantList list;

#ifdef Q_OS_WIN
    DWORD needed = 0;
    DWORD returned = 0;

    EnumPrinters(
        PRINTER_ENUM_LOCAL | PRINTER_ENUM_CONNECTIONS,
        NULL,
        2,
        NULL,
        0,
        &needed,
        &returned
    );

    if (needed == 0)
        return list;

    QByteArray buffer;
    buffer.resize(needed);

    PRINTER_INFO_2 *printers = (PRINTER_INFO_2*)buffer.data();

    if (EnumPrinters(
            PRINTER_ENUM_LOCAL | PRINTER_ENUM_CONNECTIONS,
            NULL,
            2,
            (LPBYTE)printers,
            needed,
            &needed,
            &returned))
    {
        for (DWORD i = 0; i < returned; ++i)
        {
            QVariantMap item;
            item["name"] = QString::fromWCharArray(printers[i].pPrinterName);
            item["port"] = QString::fromWCharArray(printers[i].pPortName);
            list.append(item);
        }
    }
#endif

    return list;
}

bool USBPrinterService::testPrint(const QString &printerName)
{
    EscPosBuilder builder;
    builder.initialize();
    builder.setAlignCenter();
    builder.addText("TEST PRINT");
    builder.newLine();
    builder.addText("1234567890");
    builder.newLine();
    builder.addText("ABCDEFGHIJKLMNOPQRSTUVWXYZ");
    builder.newLine();
    builder.addText("abcdefghijklmnopqrstuvwxyz");
    builder.newLine();
    builder.addText("!@#$%^&*()_+-=[]{}|;':\",.<>/?");
    builder.cut("Full Cut");

    return print(printerName, builder.data());
}
