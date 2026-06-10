#ifndef TAXCALCULATIONSERVICE_H
#define TAXCALCULATIONSERVICE_H

#include <QtGlobal>

class TaxCalculationService
{
public:
    explicit TaxCalculationService();

    qint64 calculateTax(qint64 taxableSubtotal, qint64 rate, bool enabled) const;
};

#endif // TAXCALCULATIONSERVICE_H
