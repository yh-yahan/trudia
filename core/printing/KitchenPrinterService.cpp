#include "KitchenPrinterService.h"

#include <QDebug>

KitchenPrinterService::KitchenPrinterService(SettingService &settingService,
                                            USBPrinterService &usbPrinterService,
                                            NetworkPrinterService &networkPrinterService)
    : m_settingService(settingService),
      m_usbPrinterService(usbPrinterService),
      m_networkPrinterService(networkPrinterService) {}

bool KitchenPrinterService::print(const QByteArray &data)
{
    auto settings = m_settingService.getPrinterSetting();

    QString connectionType = settings["connection_type"].toString();

    if (connectionType == "USB") {
        return m_usbPrinterService.print(
            settings["com_port"].toString(),
            data
        );
    }

    if (connectionType == "Network") {
        return m_networkPrinterService.print(
            settings["ip_address"].toString(),
            settings["port"].toInt(),
            data
        );
    }

    return false;
}
