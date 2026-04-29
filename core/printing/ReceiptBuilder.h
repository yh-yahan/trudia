#ifndef RECEIPTBUILDER_H
#define RECEIPTBUILDER_H

#include <QByteArray>
#include <QString>
#include <QDateTime>
#include "../domain/ReceiptData.h"
#include "../domain/Printer.h"

class ReceiptBuilder
{
public:
    ReceiptBuilder();

    QByteArray build(const ReceiptData &data, const Printer &printer);

private:
    QString formatAmount(double amount) const;
    QString padLeftRight(const QString &left, const QString &right, int width);
};

#endif // RECEIPTBUILDER_H
