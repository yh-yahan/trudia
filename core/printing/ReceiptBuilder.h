#ifndef RECEIPTBUILDER_H
#define RECEIPTBUILDER_H

#include <QByteArray>
#include <QString>
#include <QDateTime>
#include "../services/SettingService.h"
#include "../domain/ReceiptData.h"

class ReceiptBuilder
{
public:
    ReceiptBuilder(SettingService &settingService);

    QByteArray build(const ReceiptData &data);

private:
    SettingService &m_settingService;

    QString formatAmount(double amount) const;
};

#endif // RECEIPTBUILDER_H
