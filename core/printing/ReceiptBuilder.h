#ifndef RECEIPTBUILDER_H
#define RECEIPTBUILDER_H

#include <QByteArray>
#include <QString>
#include <QDateTime>
#include "../data/RegionalSettingsRepository.h"
#include "../domain/ReceiptData.h"
#include "../domain/Printer.h"

class ReceiptBuilder
{
public:
    ReceiptBuilder(RegionalSettingsRepository &regionalSettingsRepo);

    QByteArray build(const ReceiptData &data, const Printer &printer);

private:
    RegionalSettingsRepository &m_regionalSettingsRepo;
    QString formatAmount(double amount) const;
    QLocale getLocale() const;
    QString padLeftRight(const QString &left, const QString &right, int width);
};

#endif // RECEIPTBUILDER_H
