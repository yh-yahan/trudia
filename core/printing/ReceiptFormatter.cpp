#include "ReceiptFormatter.h"

#include "ReceiptFormatter.h"
#include <QLocale>

QString ReceiptFormatter::format(const ReceiptData &data, int lineWidth) const
{
    QString out;

    out += center(clamp(data.storeName, lineWidth), lineWidth) + "\n";
    if (!data.address.isEmpty())
        out += center(clamp(data.address, lineWidth), lineWidth) + "\n";
    if (!data.phone.isEmpty())
        out += center(clamp("Tel: " + data.phone, lineWidth), lineWidth) + "\n";
    if (!data.email.isEmpty())
        out += center(clamp(data.email, lineWidth), lineWidth) + "\n";
    if (!data.website.isEmpty())
        out += center(clamp(data.website, lineWidth), lineWidth) + "\n";

    out += divider(lineWidth) + "\n";

    out += leftRight("Subtotal", formatAmount(data.subtotal), lineWidth) + "\n";
    out += leftRight("Tax", formatAmount(data.tax), lineWidth) + "\n";
    out += divider(lineWidth) + "\n";
    out += leftRight("Total", formatAmount(data.total), lineWidth) + "\n";
    out += divider(lineWidth) + "\n\n";

    return out;
}

QString ReceiptFormatter::clamp(const QString &text, int width) const
{
    if (text.length() <= width)
        return text;
    return text.left(width);
}

QString ReceiptFormatter::center(const QString &text, int width) const
{
    if (text.length() >= width)
        return text;
    int padding = (width - text.length()) / 2;
    return QString(padding, ' ') + text;
}

QString ReceiptFormatter::leftRight(const QString &left,
                                    const QString &right,
                                    int width) const
{
    QString l = clamp(left, width);
    QString r = clamp(right, width);

    int space = width - l.length() - r.length();
    if (space < 1)
        space = 1;

    return l + QString(space, ' ') + r;
}

QString ReceiptFormatter::divider(int width) const
{
    return QString(width, '-');
}

QString ReceiptFormatter::formatAmount(double amount) const
{
    return QLocale().toString(amount, 'f', 2);
}
