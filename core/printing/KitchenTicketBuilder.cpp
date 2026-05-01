#include "KitchenTicketBuilder.h"

#include "./EscPosBuilder.h"
#include "./PrintLayoutHelper.h"

KitchenTicketBuilder::KitchenTicketBuilder(RegionalSettingsRepository &regionalSettingsRepo)
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

static QString padLeftRight(const QString &left, const QString &right, int width)
{
    int leftLen = visualWidth(left);
    int rightLen = visualWidth(right);

    int spaces = width - leftLen - rightLen;
    if (spaces < 1) spaces = 1;

    return left + QString(spaces, ' ') + right;
}

QLocale KitchenTicketBuilder::getLocale() const
{
    auto settings = m_regionalSettingsRepo.get();

    if (settings.has_value() && !settings->locale.isEmpty()) {
        return QLocale(settings->locale);
    }

    return QLocale();
}

QByteArray KitchenTicketBuilder::build(const Order &order,
                                       const OrderSession &orderSession,
                                       const std::vector<OrderItem> &items,
                                       const Printer &printer)
{
    QString paperWidth = printer.paper_width > 0
        ? QString::number(printer.paper_width) + "mm"
        : "58mm";

    int width = PrintLayoutHelper::lineWidth(paperWidth);

    EscPosBuilder b;
    b.initialize();

    b.setAlignCenter();
    b.setBold(true);
    b.addText(QObject::tr("Order #%1").arg(order.display_number));
    b.setBold(false);
    b.newLine();

    b.newLine();

    if (orderSession.order_type == "dine_in")
    {
        QString line;

        if (orderSession.table_id.has_value())
        {
            line = QObject::tr("Dine In | Table %1").arg(orderSession.table_id.value());
        }
        else
        {
            line = QObject::tr("Dine In");
        }

        b.newLine();
        b.addText(line);
        b.newLine();
    }
    else
    {
        QString orderTypeText;

        if (orderSession.order_type == "takeaway")
        {
            orderTypeText = QObject::tr("Takeaway");
        }
        else if (orderSession.order_type == "delivery")
        {
            orderTypeText = QObject::tr("Delivery");
        }
        else if (orderSession.order_type == "dine_in")
        {
            orderTypeText = QObject::tr("Dine In");
        }
        else
        {
            orderTypeText = orderSession.order_type;
        }

        b.addText(orderTypeText.toUpper());

        b.newLine();
    }

    QLocale locale = getLocale();
    QString date = locale.toString(
        QDate::currentDate(),
        QLocale::ShortFormat
    );

    QString time = QTime::currentTime().toString("HH:mm:ss");

    b.addText(date + " " + time);
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
