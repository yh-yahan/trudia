#include "SettingService.h"

SettingService::SettingService(RestaurantRepository &restaurantRepo,
                               PrinterRepository &printerRepo,
                               TaxSettingsRepository &taxSettingsRepo,
                               MembershipSettingsRepository &membershipSettingsRepo,
                               KitchenSettingsRepository &kitchenSettingsRepo,
                               RegionalSettingsRepository &regionalSettingsRepo,
                               TableSettingsRepository &tableSettingsRepo,
                               CurrencyService &currencyService)
    : m_restaurantRepo(restaurantRepo),
      m_printerRepo(printerRepo),
      m_taxSettingsRepo(taxSettingsRepo),
      m_membershipSettingsRepo(membershipSettingsRepo),
      m_kitchenSettingsRepo(kitchenSettingsRepo),
      m_regionalSettingsRepo(regionalSettingsRepo),
      m_tableSettingsRepo(tableSettingsRepo),
      m_currencyService(currencyService)
{
    auto result = m_membershipSettingsRepo.get();
    m_membershipEnabled = result.has_value() && result->enabled;

    auto settings = m_kitchenSettingsRepo.get();
    if (settings.has_value()) {
        m_kitchenMode = settings->mode;
    } else {
        m_kitchenMode = "none";
    }

    auto regionalSettings = m_regionalSettingsRepo.get();
    if (regionalSettings.has_value()) {
        m_currencyCode = regionalSettings.value().currency_code;
        emit currencyChanged();
    } else {
        m_currencyCode = "USD";
    }

    auto tableSettings = m_tableSettingsRepo.get();

    if (tableSettings.has_value()) {
        m_tableLayoutMode = tableSettings->layout_mode;
    } else {
        m_tableLayoutMode = "simple";
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

QString SettingService::tableLayoutMode() const
{
    return m_tableLayoutMode;
}

QString SettingService::currencyCode() const {
    return m_currencyCode;
}

QString SettingService::currencySymbol() const {
    return m_currencyService.getSymbol(m_currencyCode);
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

QVariantMap SettingService::getPrinter(int printerId)
{
    QVariantMap map;

    auto opt = m_printerRepo.get(printerId);
    if (!opt)
        return map;

    const Printer &p = *opt;

    map["id"] = p.id;
    map["system_name"] = p.system_name;
    map["role"] = p.role;
    map["paper_width"] = p.paper_width;
    map["cut_mode"] = p.cut_mode;

    return map;
}

QVariantList SettingService::getPrinters()
{
    QVariantList list;

    auto printers = m_printerRepo.getAll();

    for (const Printer &p : printers) {
        QVariantMap map;
        map["id"] = p.id;
        map["system_name"] = p.system_name;
        map["role"] = p.role;
        map["paper_width"] = p.paper_width;
        map["cut_mode"] = p.cut_mode;

        list.append(map);
    }

    return list;
}

bool SettingService::savePrinter(const QVariantMap &map)
{
    try {
        Printer p;

        if (map.contains("id"))
            p.id = map.value("id").toInt();

        p.system_name = map.value("system_name").toString();
        p.role = map.value("role").toString();
        p.paper_width = map.value("paper_width").toInt();
        p.cut_mode = map.value("cut_mode").toString();

        if (p.id > 0)
            m_printerRepo.update(p);
        else
            m_printerRepo.add(p);

        return true;

    } catch (const std::exception &e) {
        qWarning() << "Failed to save printer:" << e.what();
        return false;
    }
}

bool SettingService::removePrinter(int printerId)
{
    try {
        Printer p;
        p.id = printerId;

        m_printerRepo.remove(p);
        return true;

    } catch (const std::exception &e) {
        qWarning() << "Failed to remove printer:" << e.what();
        return false;
    }
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

QVariantMap SettingService::getRegionalSettings()
{
    QVariantMap map;

    auto opt = m_regionalSettingsRepo.get();
    if (!opt.has_value())
        return map;

    const auto &rs = opt.value();

    map["id"] = rs.id;

    map["locale"] = rs.locale;
    map["currency_code"] = rs.currency_code;

    auto currency = m_currencyService.get(rs.currency_code);
    map["currency_symbol"] = currency.symbol;

    return map;
}

bool SettingService::saveRegionalSettings(const QVariantMap &map)
{
    RegionalSettings rs;

    rs.id = map.value("id", 1).toInt();
    rs.locale = map.value("locale", "en_US").toString();
    rs.currency_code = map.value("currency_code", "USD").toString();

    try {
        m_regionalSettingsRepo.save(rs);

        if (m_currencyCode != rs.currency_code) {
            m_currencyCode = rs.currency_code;
            emit currencyChanged();
        }

        return true;
    } catch (const std::exception &e) {
        qWarning() << "Failed to save regional settings:" << e.what();
        return false;
    }
}

QVariantMap SettingService::getTableSettings()
{
    QVariantMap map;

    auto opt = m_tableSettingsRepo.get();

    if (!opt.has_value())
        return map;

    const TableSettings &ts = opt.value();

    map["id"] = ts.id;
    map["layout_mode"] = ts.layout_mode;

    return map;
}

bool SettingService::saveTableSettings(const QVariantMap &map)
{
    TableSettings tableSettings;

    tableSettings.id = map.value("id", 1).toInt();

    tableSettings.layout_mode =
        map.value("layout_mode", "simple").toString();

    try {
        m_tableSettingsRepo.save(tableSettings);

        if (m_tableLayoutMode != tableSettings.layout_mode) {
            m_tableLayoutMode = tableSettings.layout_mode;
            emit tableLayoutModeChanged();
        }

        return true;

    } catch (const std::exception &e) {
        qWarning() << "Failed to save table settings:"
                   << e.what();

        return false;
    }
}
