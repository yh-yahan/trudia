#include "RegionalSettingsService.h"

#include <QLocale>
#include <QString>

RegionalSettings RegionalSettingsService::detectSystemDefaults()
{
    RegionalSettings s;

    QLocale locale = QLocale::system();

    s.locale = locale.name();

    QString currency = locale.currencySymbol(QLocale::CurrencyIsoCode);

    QLocale::Country country = locale.country();

    if (currency.isEmpty()) {
        switch (country) {
        case QLocale::Malaysia: currency = "MYR"; break;
        case QLocale::UnitedStates: currency = "USD"; break;
        case QLocale::China: currency = "CNY"; break;
        case QLocale::Germany:
        case QLocale::France:
        case QLocale::Italy:
        case QLocale::Spain:
            currency = "EUR"; break;
        default: break;
        }
    }

    s.currency_code = currency;

    return s;
}

void RegionalSettingsService::ensureInitialized(RegionalSettingsRepository &repo)
{
    auto existing = repo.get();

    if (existing.has_value()) {
        return;
    }

    auto detected = detectSystemDefaults();
    
    repo.save(detected);
}
