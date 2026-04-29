#include "ReceiptBuilder.h"

#include "./EscPosBuilder.h"
#include "./PrintLayoutHelper.h"
#include <QLocale>
#include <QDateTime>

ReceiptBuilder::ReceiptBuilder() {}

static int visualWidth(const QString &s)
{
    int w = 0;

    for (QChar c : s)
    {
        if (c.unicode() < 128)
            w += 1;
        else
            w += 2;
    }

    return w;
}

QString ReceiptBuilder::formatAmount(double amount) const
{
    return QLocale().toString(amount, 'f', 2);
}

QString ReceiptBuilder::padLeftRight(const QString &left, const QString &right, int width)
{
    int leftLen = visualWidth(left);
    int rightLen = visualWidth(right);

    int spaces = width - leftLen - rightLen;
    if (spaces < 1) spaces = 1;

    return left + QString(spaces, ' ') + right;
}

QByteArray ReceiptBuilder::build(const ReceiptData &data, const Printer &printer)
{
    QString paperWidth = printer.paper_width > 0
        ? QString::number(printer.paper_width) + "mm"
        : "58mm";

    int width = PrintLayoutHelper::lineWidth(paperWidth);

    EscPosBuilder b;
    b.initialize();

    b.setAlignCenter();

    b.setBold(true);
    b.addText(data.storeName);
    b.newLine();
    b.setBold(false);

    if (!data.address.isEmpty())
    {
        b.addText(" " + data.address);
        b.newLine();
    }

    if (!data.phone.isEmpty())
    {
        b.addText("Tel: " + data.phone);
        b.newLine();
    }

    if (!data.email.isEmpty())
    {
        b.addText(data.email);
        b.newLine();
    }

    if (!data.website.isEmpty())
    {
        b.addText(data.website);
        b.newLine();
    }

    b.newLine();

    b.setAlignLeft();
    b.addText(QString(width, '-'));
    b.newLine();

    for (const auto &item : data.items)
    {
        QString left = QString("%1 x %2")
                           .arg(item.quantity)
                           .arg(item.name);

        QString right = formatAmount(item.total());

        b.setBold(true);
        b.addText(padLeftRight(left, right, width));
        b.newLine();
        b.setBold(false);

        b.addText(QString("   @ %1").arg(formatAmount(item.price)));
        b.newLine();
    }

    b.addText(QString(width, '-'));
    b.newLine();

    b.setAlignRight();

    b.addText("Subtotal: " + formatAmount(data.subtotal));
    b.newLine();

    b.addText("Tax: " + formatAmount(data.tax));
    b.newLine();

    if (data.discount > 0.0)
    {
        b.addText("Discount: -" + formatAmount(data.discount));
        b.newLine();
    }
    else
    {
        b.addText("Discount: 0");
        b.newLine();
    }

    b.setBold(true);
    b.addText("Total: " + formatAmount(data.total));
    b.setBold(false);
    b.newLine();

    b.newLine();
    b.addText(QString(width, '-'));
    b.newLine();

    if (data.membershipEnabled && !data.memberPhone.isEmpty())
    {
        b.setAlignLeft();

        if (data.pointsRedeemed > 0)
        {
            b.addText(QString(" Points Redeemed: -%1")
                          .arg(data.pointsRedeemed));
            b.newLine();
        }

        if (data.pointsEarned > 0)
        {
            b.addText(QString("Points Earned: +%1")
                          .arg(data.pointsEarned));
            b.newLine();
        }

        b.addText(QString("Balance: %1")
                      .arg(data.pointsBalance));
        b.newLine();

        b.addText(QString(width, '-'));
        b.newLine();
    }

    b.newLine();

    b.setAlignCenter();
    b.addText("Thank you!");
    b.newLine();

    b.setAlignCenter();
    b.addText(QDateTime::currentDateTime().toString("yyyy-MM-dd HH:mm"));
    b.newLine();

    b.newLine();
    b.newLine();

    QString cutMode = printer.cut_mode;
    b.cut(cutMode);

    b.newLine();
    b.newLine();

    return b.data();
}
