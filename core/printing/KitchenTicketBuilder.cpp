#include "KitchenTicketBuilder.h"

#include "./EscPosBuilder.h"
#include "./PrintLayoutHelper.h"

KitchenTicketBuilder::KitchenTicketBuilder(SettingService &settingService)
    : m_settingService(settingService) {}

QByteArray KitchenTicketBuilder::build(const Order &order,
                                       const OrderSession &orderSession,
                                       const std::vector<OrderItem> &items)
{
    auto printerOpt = m_settingService.getPrinterSetting();

    QString paperWidth = "80mm";

    if (printerOpt.contains("paper_width")) {
        paperWidth = printerOpt["paper_width"].toString();
    }

    int width = PrintLayoutHelper::lineWidth(paperWidth);

    EscPosBuilder b;
    b.initialize();

    b.setAlignLeft();
    b.addText("ORDER #" + QString::number(order.display_number));
    b.newLine();

    b.setAlignLeft();
    if (orderSession.order_type == "dine_in")
    {
        QString line = "DINE IN";

        if (orderSession.table_id.has_value())
        {
            line += " | TABLE " + QString::number(orderSession.table_id.value());
        }

        b.addText(line);
        b.newLine();
    }
    else
    {
        b.addText(orderSession.order_type.toUpper());
        b.newLine();
    }

    b.addText(QString(width, '-'));
    b.newLine();

    for (const auto &item : items)
    {
        QString qty = QString::number(item.quantity) + "x";
        QString name = item.item_name;

        int spaceWidth = width - name.length() - qty.length();

        if (spaceWidth < 1) spaceWidth = 1;

        QString line = name + QString(spaceWidth, ' ') + qty;

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

    b.setAlignRight();
    b.addText(QDateTime::currentDateTime().toString("yyyy-MM-dd HH:mm"));
    b.newLine();

    b.newLine();
    b.newLine();

    QString cutMode = printerOpt.value("cut_mode", "Full Cut").toString();
    b.cut(cutMode);

    return b.data();
}
