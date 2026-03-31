#include "ReceiptBuilder.h"

#include "./EscPosBuilder.h"
#include "./PrintLayoutHelper.h"
#include <QLocale>
#include <QDateTime>

ReceiptBuilder::ReceiptBuilder(SettingService &settingService)
    : m_settingService(settingService) {}

QByteArray ReceiptBuilder::build(const ReceiptData &data)
{
    auto printerOpt = m_settingService.getPrinterSetting();

    QString paperWidth = "80mm";
    if (printerOpt.contains("paper_width"))
    {
        paperWidth = printerOpt["paper_width"].toString();
    }

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
        b.addText(data.address);
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
        b.setBold(true);
        b.addText(QString("%1 x %2")
                      .arg(item.quantity)
                      .arg(item.name));
        b.newLine();
        b.setBold(false);

        b.addText(QString("  @ %1")
                      .arg(formatAmount(item.price)));
        b.newLine();

        b.addText(QString("  = %1")
                      .arg(formatAmount(item.total())));
        b.newLine();

        b.newLine();
    }

    b.addText(QString(width, '-'));
    b.newLine();

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

    b.addText(QString(width, '-'));
    b.newLine();

    if (data.membershipEnabled && !data.memberPhone.isEmpty())
    {
        b.newLine();

        b.setAlignLeft();
        b.addText("Member: " + data.memberPhone);
        b.newLine();

        if (data.pointsRedeemed > 0)
        {
            b.addText(QString("Points Redeemed: -%1")
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

    b.setAlignRight();
    b.addText(QDateTime::currentDateTime().toString("yyyy-MM-dd HH:mm"));
    b.newLine();

    b.newLine();
    b.newLine();

    QString cutMode = printerOpt.value("cut_mode", "Full Cut").toString();
    b.cut(cutMode);

    return b.data();
}

QString ReceiptBuilder::formatAmount(double amount) const
{
    return QLocale().toString(amount, 'f', 2);
}
