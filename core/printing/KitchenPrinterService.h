#ifndef KITCHENPRINTERSERVICE_H
#define KITCHENPRINTERSERVICE_H

#include <QByteArray>
#include "../services/SettingService.h"
#include "./USBPrinterService.h"
#include "./NetworkPrinterService.h"

class KitchenPrinterService
{
public:
    explicit KitchenPrinterService(SettingService &settingService,
                                   USBPrinterService &usbPrinterService,
                                   NetworkPrinterService &networkPrinterService);

    bool print(const QByteArray &data);

private:
    SettingService &m_settingService;
    USBPrinterService &m_usbPrinterService;
    NetworkPrinterService &m_networkPrinterService;
};

#endif // KITCHENPRINTERSERVICE_H
