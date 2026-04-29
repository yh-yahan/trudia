#include "KitchenTicketBuilder.h"

#include "./EscPosBuilder.h"
#include "./PrintLayoutHelper.h"

KitchenTicketBuilder::KitchenTicketBuilder() {}

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

static QString padLeftRight(const QString &left, const QString &right, int width)
{
    int leftLen = visualWidth(left);
    int rightLen = visualWidth(right);

    int spaces = width - leftLen - rightLen;
    if (spaces < 1) spaces = 1;

    return left + QString(spaces, ' ') + right;
}

QByteArray KitchenTicketBuilder::build(const Order &order,
                                       const OrderSession &orderSession,
                                       const std::vector<OrderItem> &items,
                                       const Printer &printer)
{
    QString paperWidth = printer.paper_width > 0
        ? QString::number(printer.paper_width) + "mm"
        : "80mm";

    int width = PrintLayoutHelper::lineWidth(paperWidth);

    EscPosBuilder b;
    b.initialize();

    b.setAlignCenter();
    b.setBold(true);
    b.addText("ORDER #" + QString::number(order.display_number));
    b.setBold(false);
    b.newLine();

    b.setAlignLeft();

    b.newLine();

    if (orderSession.order_type == "dine_in")
    {
        QString line = " DINE IN";

        if (orderSession.table_id.has_value())
        {
            line += " | TABLE " + QString::number(orderSession.table_id.value());
        }

        b.newLine();
        b.addText(line);
        b.newLine();
    }
    else
    {
        b.newLine();
        b.addText(" " + orderSession.order_type.toUpper());
        b.newLine();
    }

    b.setAlignLeft();
    b.addText(" " + QDateTime::currentDateTime().toString("yyyy-MM-dd HH:mm"));
    b.newLine();

    b.addText(QString(width, '-'));
    b.newLine();

    for (const auto &item : items)
    {
        QString qty = QString::number(item.quantity) + "x";
        QString name = " " + item.item_name;

        QString line = padLeftRight(name, qty, width);

        b.setAlignLeft();
        b.addText(line);
        b.newLine();

        if (!item.notes.isEmpty())
        {
            b.addText("  - " + item.notes);
            b.newLine();
        }

        b.newLine();
    }

    b.addText(QString(width, '-'));
    b.newLine();

    b.newLine();
    b.newLine();

    QString cutMode = printer.cut_mode;
    b.cut(cutMode);

    b.newLine();
    b.newLine();

    return b.data();
}
