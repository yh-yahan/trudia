#ifndef REGIONALSETTINGS_H
#define REGIONALSETTINGS_H

#include <QString>

struct RegionalSettings {
    int id = -1;
    QString locale;
    QString currency_code; 
};

#endif // REGIONALSETTINGS_H
