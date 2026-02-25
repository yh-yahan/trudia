#ifndef TAXCALCULATIONSERVICE_H
#define TAXCALCULATIONSERVICE_H

#include "../data/TaxSettingsRepository.h"

class TaxCalculationService
{
public:
    explicit TaxCalculationService(TaxSettingsRepository &taxSettingsRepo);

    qint64 calculateTax(qint64 subtotal) const;

private:
    TaxSettingsRepository &m_taxSettingsRepo;
};

#endif // TAXCALCULATIONSERVICE_H
