#include "SettingService.h"

SettingService::SettingService(RestaurantRepository &restaurantRepo,
                               PrinterSettingRepository  &printerSettingRepo)
    : m_restaurantRepo(restaurantRepo), m_printerSettingRepo(printerSettingRepo) {}

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
