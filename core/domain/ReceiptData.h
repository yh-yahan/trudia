#ifndef RECEIPTDATA_H
#define RECEIPTDATA_H

#include <QString>
#include <QList>

class ReceiptItem
{
public:
    QString name;
    int quantity = 0;
    double price = 0.0;

    double total() const
    {
        return price * quantity;
    }
};

class ReceiptData
{
public:
    QString storeName;
    QString address;
    QString phone;
    QString email;
    QString website;

    QString receiptNumber;
    QString displayNumber;
    QString orderType;
    std::optional<QString> tableName;

    QList<ReceiptItem> items;

    std::optional<QString> taxName;
    std::optional<double> taxRate;
    std::optional<QString> taxRegistrationNumber;

    double subtotal = 0.0;
    double tax = 0.0;
    double discount = 0.0;
    double total = 0.0;

    QString memberPhone;
    int pointsBalanceBefore = 0;
    int pointsRedeemed = 0;
    int pointsEarned = 0;
    int pointsBalanceAfter = 0;
};

#endif // RECEIPTDATA_H
