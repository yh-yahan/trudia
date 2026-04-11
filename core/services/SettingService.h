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
#include "../data/KitchenSettingsRepository.h"

class SettingService : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool membershipEnabled
            READ membershipEnabled
            NOTIFY membershipEnabledChanged)
    Q_PROPERTY(QString kitchenMode READ kitchenMode NOTIFY kitchenModeChanged)

public:
    explicit SettingService(RestaurantRepository &restaurantRepo,
                            PrinterSettingRepository &printerSettingRepo,
                            TaxSettingsRepository &taxSettingsRepo,
                            MembershipSettingsRepository &membershipSettingsRepo,
                            KitchenSettingsRepository &kitchenSettingsRepo);

    bool membershipEnabled() const;
    QString kitchenMode() const;

    Q_INVOKABLE QVariantMap getRestaurant();
    Q_INVOKABLE QVariantMap getPrinterSetting();
    Q_INVOKABLE bool saveRestaurantSetting(const QVariantMap &map);
    bool savePrinterSetting(const PrinterSetting &printerSetting);
    Q_INVOKABLE bool savePrinterSettingMap(const QVariantMap &map);
    Q_INVOKABLE bool removePrinterSetting();
    Q_INVOKABLE QVariantMap getTaxSettings();
    Q_INVOKABLE bool saveTaxSettings(const QVariantMap &map);
    Q_INVOKABLE QVariantMap getMembershipSettings();
    Q_INVOKABLE bool saveMembershipSettings(const QVariantMap &map);
    Q_INVOKABLE QVariantMap getKitchenSettings();
    Q_INVOKABLE bool saveKitchenSettings(const QVariantMap &map);

signals:
    void membershipEnabledChanged();
    void kitchenModeChanged();

private:
    RestaurantRepository &m_restaurantRepo;
    PrinterSettingRepository &m_printerSettingRepo;
    TaxSettingsRepository &m_taxSettingsRepo;
    MembershipSettingsRepository &m_membershipSettingsRepo;
    KitchenSettingsRepository &m_kitchenSettingsRepo;
    bool m_membershipEnabled = false;
    QString m_kitchenMode = "none";
};

#endif // SETTINGSERVICE_H
