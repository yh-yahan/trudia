#include "SettingService.h"

SettingService::SettingService(RestaurantRepository &restaurantRepo,
                               PrinterSettingRepository  &printerSettingRepo,
                               TaxSettingsRepository &taxSettingsRepo,
                               TaxRuleRepository &taxRuleRepo)
    : m_restaurantRepo(restaurantRepo),
      m_printerSettingRepo(printerSettingRepo),
      m_taxSettingsRepo(taxSettingsRepo),
      m_taxRuleRepo(taxRuleRepo) {}

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
    map["registration_number"] = ts.registration_number.value_or("");
    map["price_mode"] = ts.price_mode;
    map["rounding_strategy"] = ts.rounding_strategy;

    return map;
}

bool SettingService::saveTaxSettings(const QVariantMap &map)
{
    TaxSettings taxSettings;
    taxSettings.id = map.value("id", -1).toInt();
    taxSettings.enabled = map.value("enabled").toBool();
    taxSettings.registration_number = map.value("registration_number").toString();
    taxSettings.price_mode = map.value("price_mode").toString();
    taxSettings.rounding_strategy = map.value("rounding_strategy").toString();

    try {
        m_taxSettingsRepo.save(taxSettings);
        return true;
    } catch (const std::exception &e) {
        qWarning() << "Failed to save tax settings:" << e.what();
        return false;
    }
}

QVariantList SettingService::getAllTaxRule()
{
    QVariantList list;

    try {
        auto taxRules = m_taxRuleRepo.getAllTaxRules();

        for (const auto &r : taxRules) {
            QVariantMap map;

            map["id"] = r.id;
            map["name"] = r.name;

            // descale rate
            double descaledRate = static_cast<double>(r.rate) / 1000000.0;
            map["rate"] = descaledRate;

            map["scope"] = r.scope;
            map["apply_to"] = r.apply_to;
            map["priority"] = r.priority;
            map["active"] = r.active;
            map["created_at"] = r.created_at;

            list.append(map);
        }

    } catch (const std::exception &e) {
        qWarning() << "Failed to fetch tax rules:" << e.what();
    }

    return list;
}

bool SettingService::addTaxRule(const QVariantMap &map)
{
    TaxRule taxRule;

    taxRule.name = map.value("name").toString();

    double fractionalRate = map.value("rate").toDouble();

    // Scale to integer (fraction * 1,000,000)
    taxRule.rate = static_cast<int>(fractionalRate * 1000000.0);

    taxRule.scope = map.value("scope").toString();
    taxRule.apply_to = map.value("apply_to").toString();
    taxRule.priority = map.value("priority").toInt();
    taxRule.active = map.value("active").toBool();

    try {
        m_taxRuleRepo.create(taxRule);
        return true;
    } catch (const std::exception &e) {
        qWarning() << "Failed to create tax rule:" << e.what();
        return false;
    }
}

bool SettingService::setTaxRuleActiveStatus(const QVariantMap &map, const bool &setActive)
{
    int id = map.value("id").toInt();

    try {
        auto taxRuleOpt = m_taxRuleRepo.getTaxRulesById(id);
        if (!taxRuleOpt.has_value()) {
            qWarning() << "Tax rule not found with id:" << id;
            return false;
        }

        if (setActive) {
            m_taxRuleRepo.setActive(taxRuleOpt.value());
        } else {
            m_taxRuleRepo.setInactive(taxRuleOpt.value());
        }

        return true;

    } catch (const std::exception &e) {
        qWarning() << "Failed to update tax rule active status:" << e.what();
        return false;
    }
}
