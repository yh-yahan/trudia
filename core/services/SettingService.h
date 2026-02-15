#ifndef SETTINGSERVICE_H
#define SETTINGSERVICE_H

#include <QObject>
#include <QString>
#include <QVariantList>
#include <QVariantMap>
#include "../data/RestaurantRepository.h"
#include "../data/PrinterSettingRepository.h"

class SettingService : public QObject
{
    Q_OBJECT

public:
    explicit SettingService(RestaurantRepository &restaurantRepo,
                            PrinterSettingRepository  &printerSettingRepo);

    Q_INVOKABLE QVariantMap getRestaurant();
    Q_INVOKABLE QVariantMap getPrinterSetting();
    Q_INVOKABLE bool saveRestaurantSetting(const QVariantMap &map);
    bool savePrinterSetting(const PrinterSetting &printerSetting);
    Q_INVOKABLE bool savePrinterSettingMap(const QVariantMap &map);

private:
    RestaurantRepository &m_restaurantRepo;
    PrinterSettingRepository  &m_printerSettingRepo;
};

#endif // SETTINGSERVICE_H
