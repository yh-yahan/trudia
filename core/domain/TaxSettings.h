#ifndef TAXSETTINGS_H
#define TAXSETTINGS_H

#include <QString>

class TaxSettings
{
public:
    int id = -1;
    bool enabled;
    int rate;
    std::optional<QString> registration_number;
    QString name;
    std::optional<QString> created_at;
};

#endif // TAXSETTINGS_H
