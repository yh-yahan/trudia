#include "SettingService.h"

SettingService::SettingService(RestaurantRepository &restaurantRepo,
                               PrinterSettingRepository &printerSettingRepo,
                               TaxSettingsRepository &taxSettingsRepo,
                               MembershipSettingsRepository &membershipSettingsRepo)
    : m_restaurantRepo(restaurantRepo),
      m_printerSettingRepo(printerSettingRepo),
      m_taxSettingsRepo(taxSettingsRepo),
      m_membershipSettingsRepo(membershipSettingsRepo){}

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
    s.id = map.value("id", -1).toInt();
    s.printer_interface = map.value("printer_interface").toString();
    s.connection_type = map.value("connection_type").toString();
    s.ip_address = map.value("ip_address").toString();
    s.port = map.value("port").toInt();
    s.com_port = map.value("com_port").toString();
    s.baud_rate = map.value("baud_rate").toInt();
    s.parity = map.value("parity").toString();
    s.data_bits = map.value("data_bits").toInt();
    s.stop_bits = map.value("stop_bits").toInt();
    s.flow_control = map.value("flow_control").toString();
    s.paper_width = map.value("paper_width").toString();
    s.char_per_line = map.value("char_per_line").toInt();
    s.cut_mode = map.value("cut_mode").toString();

    return savePrinterSetting(s);
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
    map["earn_rate"] = ms.earn_rate;
    map["min_spend"] = ms.min_spend;
    map["earn_on"] = ms.earn_on;
    map["conversion"] = ms.conversion;
    map["redeem_min_point"] = ms.redeem_min_point;
    map["partial_redemption"] = ms.partial_redemption;

    return map;
}

bool SettingService::saveMembershipSettings(const QVariantMap &map)
{
    MembershipSettings membershipSettings;
    membershipSettings.id = map.value("id", 1).toInt();
    membershipSettings.enabled = map.value("enabled").toBool();
    membershipSettings.earn_rate = map.value("earn_rate").toInt();
    membershipSettings.min_spend = map.value("min_spend").toInt();
    membershipSettings.earn_on = map.value("earn_on").toString();
    membershipSettings.conversion = map.value("conversion").toInt();
    membershipSettings.redeem_min_point = map.value("redeem_min_point").toInt();
    membershipSettings.partial_redemption = map.value("partial_redemption").toInt();

    try {
        m_membershipSettingsRepo.save(membershipSettings);
        return true;
    } catch (const std::exception &e) {
        qWarning() << "Failed to save membership settings:" << e.what();
        return false;
    }
}
