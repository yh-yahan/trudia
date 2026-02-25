#ifndef SETTINGSERVICE_H
#define SETTINGSERVICE_H

#include <QObject>
#include <QString>
#include <QVariantList>
#include <QVariantMap>
#include "../data/RestaurantRepository.h"
#include "../data/PrinterSettingRepository.h"
#include "../data/TaxSettingsRepository.h"

class SettingService : public QObject
{
    Q_OBJECT

public:
    explicit SettingService(RestaurantRepository &restaurantRepo,
                            PrinterSettingRepository &printerSettingRepo,
                            TaxSettingsRepository &taxSettingsRepo);

    Q_INVOKABLE QVariantMap getRestaurant();
    Q_INVOKABLE QVariantMap getPrinterSetting();
    Q_INVOKABLE bool saveRestaurantSetting(const QVariantMap &map);
    bool savePrinterSetting(const PrinterSetting &printerSetting);
    Q_INVOKABLE bool savePrinterSettingMap(const QVariantMap &map);
    Q_INVOKABLE QVariantMap getTaxSettings();
    Q_INVOKABLE bool saveTaxSettings(const QVariantMap &map);

private:
    RestaurantRepository &m_restaurantRepo;
    PrinterSettingRepository &m_printerSettingRepo;
    TaxSettingsRepository &m_taxSettingsRepo;
};

#endif // SETTINGSERVICE_H
