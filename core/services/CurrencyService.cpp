#include "CurrencyService.h"

const QHash<QString, CurrencyService::CurrencyInfo>& CurrencyService::currencyMap()
{
    static const QHash<QString, CurrencyInfo> map = {
        {
            "USD",
            {"USD", "$", "US Dollar", 2, "prefix"}
        },
        {
            "EUR",
            {"EUR", "€", "Euro", 2, "prefix"}
        },
        {
            "JPY",
            {"JPY", "¥", "Japanese Yen", 0, "prefix"}
        },
        {
            "MYR",
            {"MYR", "RM", "Malaysian Ringgit", 2, "prefix"}
        },
        {
            "GBP",
            {"GBP", "£", "British Pound", 2, "prefix"}
        },
        {
            "CNY",
            {"CNY", "¥", "Chinese Yuan", 2, "prefix"}
        }
    };

    return map;
}

CurrencyService::CurrencyInfo CurrencyService::get(const QString &code)
{
    const auto &map = currencyMap();

    if (map.contains(code))
        return map.value(code);

    return {
        code,
        "$",
        "Unknown Currency",
        2,
        "prefix"
    };
}

QList<CurrencyService::CurrencyInfo> CurrencyService::all()
{
    return currencyMap().values();
}
