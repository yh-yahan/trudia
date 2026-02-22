#include "TaxRuleRepository.h"

#include <QSqlQuery>
#include <QSqlError>
#include <QVariant>
#include <QDebug>

TaxRuleRepository::TaxRuleRepository(QSqlDatabase db): m_db(db) {}

std::vector<TaxRule> TaxRuleRepository::getAllTaxRules()
{
    std::vector<TaxRule> taxRules;

    QSqlQuery query(m_db);
    query.prepare("SELECT id, name, rate, scope, apply_to, priority, active, created_at FROM tax_rules");

    if (!query.exec()) {
        qWarning() << "getAllTaxRules failed:" << query.lastError();
        return taxRules;
    }

    while (query.next()) {
        TaxRule taxRule;
        taxRule.id = query.value("id").toInt();
        taxRule.name = query.value("name").toString();
        taxRule.rate = query.value("rate").toInt();
        taxRule.scope = query.value("scope").toString();
        taxRule.apply_to = query.value("apply_to").toString();
        taxRule.priority = query.value("priority").toInt();
        taxRule.active = query.value("active").toBool();
        taxRule.created_at = query.value("created_at").toString();

        taxRules.push_back(taxRule);
    }

    return taxRules;
}

std::optional<TaxRule> TaxRuleRepository::getTaxRulesById(int taxRuleId)
{
    QSqlQuery query(m_db);
    query.prepare(R"(SELECT id, name, rate, scope, apply_to, priority, active, created_at
        FROM tax_rules
        WHERE id = :id)");
    query.bindValue(":id", taxRuleId);

    if (!query.exec()) {
        qWarning() << "getTaxRulesById failed:" << query.lastError();
        return std::nullopt;
    }

    if (!query.next()) {
        return std::nullopt;
    }

    TaxRule taxRule;
    taxRule.id = query.value("id").toInt();
    taxRule.name = query.value("name").toString();
    taxRule.rate = query.value("rate").toInt();
    taxRule.scope = query.value("scope").toString();
    taxRule.apply_to = query.value("apply_to").toString();
    taxRule.priority = query.value("priority").toBool();
    taxRule.active = query.value("active").toBool();
    taxRule.created_at = query.value("created_at").toString();

    return taxRule;
}

void TaxRuleRepository::create(const TaxRule &taxRule)
{
    QSqlQuery query(m_db);
    query.prepare(R"(
        INSERT INTO tax_rules (name, rate, scope, apply_to, priority, active)
        VALUES (:name, :rate, :scope, :apply_to, :priority, :active)
    )");

    query.bindValue(":name", taxRule.name);
    query.bindValue(":rate", taxRule.rate);
    query.bindValue(":scope", taxRule.scope);
    query.bindValue(":apply_to", taxRule.apply_to);
    query.bindValue(":priority", taxRule.priority);
    query.bindValue(":active", taxRule.active);

    if (!query.exec()) {
        qWarning() << "create failed:" << query.lastError();
    }
}

void TaxRuleRepository::setActive(const TaxRule &taxRule)
{
    QSqlQuery query(m_db);
    query.prepare(R"(
        UPDATE tax_rules
        SET active = :active
        WHERE id = :id
    )");

    query.bindValue(":active", true);
    query.bindValue(":id", taxRule.id);

    if (!query.exec()) {
        qWarning() << "setInactive failed:" << query.lastError();
    }
}

void TaxRuleRepository::setInactive(const TaxRule &taxRule)
{
    QSqlQuery query(m_db);
    query.prepare(R"(
        UPDATE tax_rules
        SET active = :active
        WHERE id = :id
    )");

    query.bindValue(":active", false);
    query.bindValue(":id", taxRule.id);

    if (!query.exec()) {
        qWarning() << "setInactive failed:" << query.lastError();
    }
}
