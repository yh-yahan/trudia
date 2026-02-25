#include "TaxCalculationService.h"

TaxCalculationService::TaxCalculationService(TaxSettingsRepository &taxSettingsRepo) :
                    m_taxSettingsRepo(taxSettingsRepo) {}

qint64 TaxCalculationService::calculateTax(qint64 subtotal) const
{
    auto settingsOpt = m_taxSettingsRepo.get();
    if (!settingsOpt.has_value())
        return 0;

    const auto &settings = settingsOpt.value();
    if (!settings.enabled)
        return 0;

    const qint64 tax = (subtotal * settings.rate) / 100000000;
    return tax;
}
