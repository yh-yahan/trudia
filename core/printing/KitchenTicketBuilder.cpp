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

    b.setAlignCenter();
    b.setBold(true);
    b.addText("ORDER #" + QString::number(order.display_number));
    b.newLine();
    b.setBold(false);

    b.setAlignLeft();
    if (orderSession.order_type == "dine_in")
    {
        b.addText("DINE IN");
        b.newLine();

        if (orderSession.table_id.has_value())
        {
            b.addText("Table: " + QString::number(orderSession.table_id.value()));
            b.newLine();
        }
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
        QString line = QString::number(item.quantity) + "x " + item.item_name;

        b.setBold(true);
        b.addText(line);
        b.newLine();
        b.setBold(false);

        if (!item.notes.isEmpty())
        {
            b.addText("  * " + item.notes);
            b.newLine();
        }

        b.newLine();
    }

    b.addText(QString(width, '-'));
    b.newLine();

    b.setAlignRight();
    b.addText(QDateTime::currentDateTime().toString("HH:mm"));
    b.newLine();
    b.newLine();

    QString cutMode = printerOpt.value("cut_mode", "Full Cut").toString();
    b.cut(cutMode);

    return b.data();
}
