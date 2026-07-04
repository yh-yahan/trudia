#include "ReceiptBuilder.h"

#include "./EscPosBuilder.h"
#include "./PrintLayoutHelper.h"
#include <QLocale>
#include <QDateTime>

ReceiptBuilder::ReceiptBuilder(RegionalSettingsRepository &regionalSettingsRepo)
    : m_regionalSettingsRepo(regionalSettingsRepo) {}

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
    QLocale locale = getLocale();
    return locale.toString(amount, 'f', 2);
}

QString ReceiptBuilder::padLeftRight(const QString &left, const QString &right, int width)
{
    int leftLen = visualWidth(left);
    int rightLen = visualWidth(right);

    int spaces = width - leftLen - rightLen;
    if (spaces < 1) spaces = 1;

    return left + QString(spaces, ' ') + right;
}

QLocale ReceiptBuilder::getLocale() const
{
    auto settings = m_regionalSettingsRepo.get();

    if (settings.has_value() && !settings->locale.isEmpty()) {
        return QLocale(settings->locale);
    }

    return QLocale();
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

    if (data.taxRegistrationNumber && !data.taxRegistrationNumber->isEmpty())
    {
        b.addText(QObject::tr("%1 Reg. No.: %2")
                        .arg((data.taxName && !data.taxName->isEmpty()) ? *data.taxName : "Tax")
                        .arg(*data.taxRegistrationNumber));
        b.newLine();
    }

    b.newLine();
    b.addText(QString(width, '-'));
    b.newLine();

    b.setAlignLeft();

    if (!data.receiptNumber.isEmpty())
    {
        b.addText(QObject::tr("Receipt #: %1").arg(data.receiptNumber));
        b.newLine();
    }

    if (!data.displayNumber.isEmpty())
    {
        b.addText(QObject::tr("Order #: %1").arg(data.displayNumber));
        b.newLine();
    }

    if (!data.orderType.isEmpty())
    {
        b.addText(QObject::tr("Order Type: %1").arg(data.orderType));
        b.newLine();
    }

    if (data.tableName.has_value())
    {
        b.addText(QObject::tr("Table: %1").arg(data.tableName.value()));
        b.newLine();
    }

    QLocale locale = getLocale();
    QString date = locale.toString(
        QDate::currentDate(),
        QLocale::ShortFormat
    );

    QString time = QTime::currentTime().toString("HH:mm:ss");

    b.addText(QObject::tr("Date: %1 %2").arg(date, time));
    b.newLine();

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

    b.addText(QObject::tr("Subtotal: %1").arg(formatAmount(data.subtotal)));
    b.newLine();

    if (data.tax > 0.0 || (data.taxName && !data.taxName->isEmpty()))
    {
        QString taxLabel;

        if (data.taxName && !data.taxName->isEmpty() && data.taxRate.has_value() && data.taxRate.value() > 0.0)
        {
            taxLabel = QObject::tr("Tax (%1 %2%)")
            .arg(*data.taxName)
                .arg(QString::number(data.taxRate.value(), 'f', 2));
        }
        else if (data.taxName && !data.taxName->isEmpty())
        {
            taxLabel = *data.taxName;
        }
        else
        {
            taxLabel = QObject::tr("Tax");
        }

        b.addText(QObject::tr("%1: %2")
                      .arg(taxLabel)
                      .arg(formatAmount(data.tax)));
        b.newLine();
    }

    if (data.discount > 0.0)
    {
        b.addText(QObject::tr("Discount: -%1").arg(formatAmount(data.discount)));
        b.newLine();
    }
    else
    {
        b.addText(QObject::tr("Discount: %1").arg("0"));
        b.newLine();
    }

    b.setBold(true);
    b.addText(QObject::tr("Total: %1").arg(formatAmount(data.total)));
    b.setBold(false);
    b.newLine();

    b.newLine();
    b.addText(QString(width, '-'));
    b.newLine();

    if (!data.memberPhone.isEmpty())
    {
        b.addText(QObject::tr("Balance Before: %1")
              .arg(data.pointsBalanceBefore));
        b.newLine();
        
        if (data.pointsRedeemed > 0)
        {
            b.addText(QObject::tr("Points Redeemed: -%1")
                .arg(data.pointsRedeemed));
            b.newLine();
        }

        if (data.pointsEarned > 0)
        {
            b.addText(QObject::tr("Points Earned: +%1")
                .arg(data.pointsEarned));
            b.newLine();
        }

        b.addText(QObject::tr("Balance After: %1")
              .arg(data.pointsBalanceAfter));
        b.newLine();

        b.addText(QString(width, '-'));
        b.newLine();
    }

    b.newLine();

    b.setAlignCenter();
    b.addText(QObject::tr("Thank you!"));
    b.newLine();

    b.newLine();
    b.newLine();

    QString cutMode = printer.cut_mode;
    b.cut(cutMode);

    b.newLine();
    b.newLine();

    return b.data();
}
