#ifndef SETTINGSERVICE_H
#define SETTINGSERVICE_H

#include <QObject>
#include <QString>
#include <QVariantList>
#include <QVariantMap>
#include "../data/RestaurantRepository.h"
#include "../data/PrinterSettingRepository.h"
#include "../data/TaxSettingsRepository.h"
#include "../data/MembershipSettingsRepository.h"

class SettingService : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool membershipEnabled
            READ membershipEnabled
            NOTIFY membershipEnabledChanged)

public:
    explicit SettingService(RestaurantRepository &restaurantRepo,
                            PrinterSettingRepository &printerSettingRepo,
                            TaxSettingsRepository &taxSettingsRepo,
                            MembershipSettingsRepository &membershipSettingsRepo);

    bool membershipEnabled() const;

    Q_INVOKABLE QVariantMap getRestaurant();
    Q_INVOKABLE QVariantMap getPrinterSetting();
    Q_INVOKABLE bool saveRestaurantSetting(const QVariantMap &map);
    bool savePrinterSetting(const PrinterSetting &printerSetting);
    Q_INVOKABLE bool savePrinterSettingMap(const QVariantMap &map);
    Q_INVOKABLE QVariantMap getTaxSettings();
    Q_INVOKABLE bool saveTaxSettings(const QVariantMap &map);
    Q_INVOKABLE QVariantMap getMembershipSettings();
    Q_INVOKABLE bool saveMembershipSettings(const QVariantMap &map);

signals:
    void membershipEnabledChanged();

private:
    RestaurantRepository &m_restaurantRepo;
    PrinterSettingRepository &m_printerSettingRepo;
    TaxSettingsRepository &m_taxSettingsRepo;
    MembershipSettingsRepository &m_membershipSettingsRepo;
    bool m_membershipEnabled = false;
};

#endif // SETTINGSERVICE_H
