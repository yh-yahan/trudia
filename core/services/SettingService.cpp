#include "SettingService.h"

SettingService::SettingService(RestaurantRepository &restaurantRepo,
                               PrinterSettingRepository &printerSettingRepo,
                               TaxSettingsRepository &taxSettingsRepo,
                               MembershipSettingsRepository &membershipSettingsRepo,
                               KitchenSettingsRepository &kitchenSettingsRepo)
    : m_restaurantRepo(restaurantRepo),
      m_printerSettingRepo(printerSettingRepo),
      m_taxSettingsRepo(taxSettingsRepo),
      m_membershipSettingsRepo(membershipSettingsRepo),
      m_kitchenSettingsRepo(kitchenSettingsRepo)
{
    auto result = m_membershipSettingsRepo.get();
    m_membershipEnabled = result.has_value() && result->enabled;

    auto settings = m_kitchenSettingsRepo.get();
    if (settings.has_value()) {
        m_kitchenMode = settings->mode;
    } else {
        m_kitchenMode = "none";
    }
}

bool SettingService::membershipEnabled() const
{
    return m_membershipEnabled;
}

QString SettingService::kitchenMode() const
{
    return m_kitchenMode;
}

QVariantMap SettingService::getRestaurant()
{
    QVariantMap map;
    auto restaurantOpt = m_restaurantRepo.get();
    if (!restaurantOpt.has_value())
        return map;

    const Restaurant &r = restaurantOpt.value();
    map["id"] = r.id;
    map["name"] = r.name;
    map["address"] = r.address;
    map["phone_number"] = r.phone_number.value_or("");
    map["email"] = r.email.value_or("");
    map["website"] = r.website.value_or("");
    return map;
}

QVariantMap SettingService::getPrinterSetting()
{
    QVariantMap map;

    auto settingOpt = m_printerSettingRepo.get();
    if (!settingOpt.has_value())
        return map;

    const PrinterSetting &s = settingOpt.value();

    map["id"] = s.id;
    map["printer_interface"] = s.printer_interface;
    map["connection_type"] = s.connection_type.value_or("");
    map["ip_address"] = s.ip_address.value_or("");
    map["port"] = s.port.value_or(0);
    map["com_port"] = s.com_port.value_or("");
    map["baud_rate"] = s.baud_rate.value_or(0);
    map["parity"] = s.parity.value_or("");
    map["data_bits"] = s.data_bits.value_or(0);
    map["stop_bits"] = s.stop_bits.value_or(0);
    map["flow_control"] = s.flow_control.value_or("");
    map["paper_width"] = s.paper_width;
    map["char_per_line"] = s.char_per_line;
    map["cut_mode"] = s.cut_mode;

    return map;
}

bool SettingService::saveRestaurantSetting(const QVariantMap &map)
{
    Restaurant restaurant;
    restaurant.id = map.value("id", -1).toInt();
    restaurant.name = map.value("name").toString();
    restaurant.address = map.value("address").toString();
    restaurant.phone_number = map.value("phone_number").toString();
    restaurant.email = map.value("email").toString();
    restaurant.website = map.value("website").toString();

    try {
        m_restaurantRepo.save(restaurant);
        return true;
    } catch (const std::exception &e) {
        qWarning() << "Failed to save restaurant:" << e.what();
        return false;
    }
}

bool SettingService::savePrinterSetting(const PrinterSetting &printerSetting)
{
    try {
        m_printerSettingRepo.save(printerSetting);
        return true;
    } catch (const std::exception &e) {
        qWarning() << "Failed to save printer setting:" << e.what();
        return false;
    }
}

bool SettingService::savePrinterSettingMap(const QVariantMap &map)
{
    PrinterSetting s;

    auto existingOpt = m_printerSettingRepo.get();
    if (existingOpt.has_value()) {
        s = existingOpt.value();
    }

    if (map.contains("printer_interface"))
        s.printer_interface = map.value("printer_interface").toString();

    if (map.contains("connection_type"))
        s.connection_type = map.value("connection_type").toString();

    if (map.contains("ip_address"))
        s.ip_address = map.value("ip_address").toString();

    if (map.contains("port"))
        s.port = map.value("port").toInt();

    if (map.contains("com_port"))
        s.com_port = map.value("com_port").toString();

    if (map.contains("baud_rate"))
        s.baud_rate = map.value("baud_rate").toInt();

    if (map.contains("parity"))
        s.parity = map.value("parity").toString();

    if (map.contains("data_bits"))
        s.data_bits = map.value("data_bits").toInt();

    if (map.contains("stop_bits"))
        s.stop_bits = map.value("stop_bits").toInt();

    if (map.contains("flow_control"))
        s.flow_control = map.value("flow_control").toString();

    if (map.contains("paper_width"))
        s.paper_width = map.value("paper_width").toString();

    if (map.contains("char_per_line"))
        s.char_per_line = map.value("char_per_line").toInt();

    if (map.contains("cut_mode"))
        s.cut_mode = map.value("cut_mode").toString();

    return savePrinterSetting(s);
}

bool SettingService::removePrinterSetting()
{
    PrinterSetting empty;
    return savePrinterSetting(empty);
}

QVariantMap SettingService::getTaxSettings()
{
    QVariantMap map;

    auto taxSettingsOpt = m_taxSettingsRepo.get();
    if (!taxSettingsOpt.has_value())
        return map;

    const TaxSettings &ts = taxSettingsOpt.value();
    map["id"] = ts.id;
    map["enabled"] = ts.enabled;
    map["rate"] = ts.rate;
    map["registration_number"] = ts.registration_number.value_or("");
    map["name"] = ts.name;

    return map;
}

bool SettingService::saveTaxSettings(const QVariantMap &map)
{
    TaxSettings taxSettings;
    taxSettings.id = map.value("id", -1).toInt();
    taxSettings.enabled = map.value("enabled").toBool();
    taxSettings.registration_number = map.value("registration_number").toString();
    taxSettings.rate = map.value("rate").toInt();
    taxSettings.name = map.value("name").toString();

    try {
        m_taxSettingsRepo.save(taxSettings);
        return true;
    } catch (const std::exception &e) {
        qWarning() << "Failed to save tax settings:" << e.what();
        return false;
    }
}

QVariantMap SettingService::getMembershipSettings()
{
    QVariantMap map;

    auto membershipSettingsOpt = m_membershipSettingsRepo.get();
    if (!membershipSettingsOpt.has_value())
        return map;

    const MembershipSettings &ms = membershipSettingsOpt.value();

    map["id"] = ms.id;
    map["enabled"] = ms.enabled;
    map["earn_points"] = ms.earn_points;
    map["earn_spend"] = ms.earn_spend / 100.0;
    map["redeem_points"] = ms.redeem_points;
    map["redeem_value"] = ms.redeem_value / 100.0;

    map["earn_on"] = ms.earn_on;

    return map;
}

bool SettingService::saveMembershipSettings(const QVariantMap &map)
{
    MembershipSettings membershipSettings;

    membershipSettings.id = 1;
    membershipSettings.enabled = map["enabled"].toBool();

    membershipSettings.earn_points = map["earn_points"].toInt();

    membershipSettings.earn_spend = map["earn_spend"].toDouble() * 100.0;

    membershipSettings.redeem_points = map["redeem_points"].toInt();

    membershipSettings.redeem_value = map["redeem_value"].toDouble() * 100.0;

    membershipSettings.earn_on = map["earn_on"].toString();

    m_membershipSettingsRepo.save(membershipSettings);

    if (m_membershipEnabled != membershipSettings.enabled) {
        m_membershipEnabled = membershipSettings.enabled;
        emit membershipEnabledChanged();
    }

    return true;
}

QVariantMap SettingService::getKitchenSettings()
{
    QVariantMap map;

    auto kitchenSettingsOpt = m_kitchenSettingsRepo.get();
    if (!kitchenSettingsOpt.has_value())
        return map;

    const KitchenSettings &ks = kitchenSettingsOpt.value();

    map["id"] = ks.id;
    map["mode"] = ks.mode;
    map["ticket_print_timing"] = ks.ticket_print_timing;
    map["require_ready_for_checkout"] = ks.require_ready_for_checkout;
    map["allow_edit_after_send"] = ks.allow_edit_after_send;

    return map;
}

bool SettingService::saveKitchenSettings(const QVariantMap &map)
{
    KitchenSettings kitchenSettings;

    kitchenSettings.id = map.value("id", 1).toInt();
    kitchenSettings.mode = map.value("mode").toString();
    kitchenSettings.ticket_print_timing = map.value("ticket_print_timing").toString();
    kitchenSettings.require_ready_for_checkout = map.value("require_ready_for_checkout").toBool();
    kitchenSettings.allow_edit_after_send = map.value("allow_edit_after_send").toBool();

    try {
        m_kitchenSettingsRepo.save(kitchenSettings);

        if (m_kitchenMode != kitchenSettings.mode) {
            m_kitchenMode = kitchenSettings.mode;
            emit kitchenModeChanged();
        }

        return true;
    } catch (const std::exception &e) {
        qWarning() << "Failed to save kitchen settings:" << e.what();
        return false;
    }
}
