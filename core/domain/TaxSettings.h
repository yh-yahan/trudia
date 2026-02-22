#ifndef TAXSETTINGS_H
#define TAXSETTINGS_H

#include <QString>

class TaxSettings
{
public:
    int id = -1;
    bool enabled;
    std::optional<QString> registration_number;
    QString price_mode; // exclusive/inclusive
    QString rounding_strategy; // per_line/per_order
    std::optional<QString> created_at;
};

#endif // TAXSETTINGS_H
