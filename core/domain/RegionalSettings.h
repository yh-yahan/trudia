#ifndef REGIONALSETTINGS_H
#define REGIONALSETTINGS_H

#include <QString>

class RegionalSettings
{
public:
    int id = -1;
    QString locale;
    QString currency_code;
    QString timezone;
    QString date_format;
    QString time_format;
};

#endif // REGIONALSETTINGS_H
