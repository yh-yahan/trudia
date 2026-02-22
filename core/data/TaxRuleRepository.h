#ifndef TAXRULEREPOSITORY_H
#define TAXRULEREPOSITORY_H

#include <QString>
#include <QSqlDatabase>
#include "../domain/TaxRule.h"

class TaxRuleRepository
{
public:
    explicit TaxRuleRepository(QSqlDatabase db);

    std::vector<TaxRule> getAllTaxRules();
    std::optional<TaxRule> getTaxRulesById(int taxRuleId);
    void create(const TaxRule &taxRule);
    void setActive(const TaxRule &taxRule);
    void setInactive(const TaxRule &taxRule);

private:
    QSqlDatabase m_db;
};

#endif // TAXRULEREPOSITORY_H
