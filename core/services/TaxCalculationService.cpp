#include "TaxCalculationService.h"

TaxCalculationService::TaxCalculationService(TaxSettingsRepository &taxSettingsRepo) :
                    m_taxSettingsRepo(taxSettingsRepo) {}

qint64 TaxCalculationService::calculateTax(qint64 lineTotal) const
{
    auto settingsOpt = m_taxSettingsRepo.get();
    if (!settingsOpt.has_value())
        return 0;

    const auto &settings = settingsOpt.value();
    if (!settings.enabled)
        return 0;

    const qint64 tax = (lineTotal * settings.rate) / 100000000;
    return tax;
}
