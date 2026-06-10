#include "TaxCalculationService.h"

TaxCalculationService::TaxCalculationService() {}

qint64 TaxCalculationService::calculateTax(qint64 taxableSubtotal, qint64 rate, bool enabled) const
{
    if (!enabled)
        return 0;

    return (taxableSubtotal * rate) / 10000;
}
