#ifndef SETTINGSERVICE_H
#define SETTINGSERVICE_H

#include <QObject>
#include <QString>
#include <QVariantList>
#include <QVariantMap>
#include "../data/RestaurantRepository.h"
#include "../data/PrinterRepository.h"
#include "../data/TaxSettingsRepository.h"
#include "../data/MembershipSettingsRepository.h"
#include "../data/KitchenSettingsRepository.h"
#include "../data/RegionalSettingsRepository.h"
#include "./CurrencyService.h"

class SettingService : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool membershipEnabled
            READ membershipEnabled
            NOTIFY membershipEnabledChanged)
    Q_PROPERTY(QString kitchenMode READ kitchenMode NOTIFY kitchenModeChanged)
    Q_PROPERTY(QString currencyCode READ currencyCode NOTIFY currencyChanged)

public:
    explicit SettingService(RestaurantRepository &restaurantRepo,
                            PrinterRepository &printerRepo,
                            TaxSettingsRepository &taxSettingsRepo,
                            MembershipSettingsRepository &membershipSettingsRepo,
                            KitchenSettingsRepository &kitchenSettingsRepo,
                            RegionalSettingsRepository &regionalSettingsRepo,
                            CurrencyService &currencyService);

    bool membershipEnabled() const;
    QString kitchenMode() const;
    QString currencyCode() const;

    Q_INVOKABLE QString currencySymbol() const;

    Q_INVOKABLE QVariantMap getRestaurant();
    Q_INVOKABLE bool saveRestaurantSetting(const QVariantMap &map);
    Q_INVOKABLE QVariantMap getPrinter(int printerId);
    Q_INVOKABLE QVariantList getPrinters();
    Q_INVOKABLE bool savePrinter(const QVariantMap &map);
    Q_INVOKABLE bool removePrinter(int printerId);
    Q_INVOKABLE QVariantMap getTaxSettings();
    Q_INVOKABLE bool saveTaxSettings(const QVariantMap &map);
    Q_INVOKABLE QVariantMap getMembershipSettings();
    Q_INVOKABLE bool saveMembershipSettings(const QVariantMap &map);
    Q_INVOKABLE QVariantMap getKitchenSettings();
    Q_INVOKABLE bool saveKitchenSettings(const QVariantMap &map);
    Q_INVOKABLE QVariantMap getRegionalSettings();
    Q_INVOKABLE bool saveRegionalSettings(const QVariantMap &map);

signals:
    void membershipEnabledChanged();
    void kitchenModeChanged();
    void currencyChanged();

private:
    RestaurantRepository &m_restaurantRepo;
    PrinterRepository m_printerRepo;
    TaxSettingsRepository &m_taxSettingsRepo;
    MembershipSettingsRepository &m_membershipSettingsRepo;
    KitchenSettingsRepository &m_kitchenSettingsRepo;
    RegionalSettingsRepository &m_regionalSettingsRepo;
    CurrencyService &m_currencyService;
    bool m_membershipEnabled = false;
    QString m_kitchenMode = "none";
    QString m_currencyCode;
};

#endif // SETTINGSERVICE_H
