#ifndef REGIONALSETTINGSSERVICE_H
#define REGIONALSETTINGSSERVICE_H

#include "../data/RegionalSettingsRepository.h"

class RegionalSettingsService
{
public:
    RegionalSettings detectSystemDefaults();
    void ensureInitialized(RegionalSettingsRepository &repo);
};

#endif // REGIONALSETTINGSSERVICE_H
