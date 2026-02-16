#ifndef RECEIPTFORMATTER_H
#define RECEIPTFORMATTER_H

#include <QString>

struct ReceiptData
{
    QString storeName;
    QString address;
    QString phone;
    QString email;
    QString website;

    double subtotal = 0.0;
    double tax = 0.0;
    double total = 0.0;
};

class ReceiptFormatter
{
public:
    QString format(const ReceiptData &data,
                   int lineWidth) const;

private:
    QString clamp(const QString &text, int width) const;
    QString center(const QString &text, int width) const;
    QString leftRight(const QString &left,
                      const QString &right,
                      int width) const;
    QString divider(int width) const;
    QString formatAmount(double amount) const;
};

#endif // RECEIPTFORMATTER_H
