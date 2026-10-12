#include "CategoryRepository.h"

#include <QSqlQuery>
#include <QSqlError>
#include <QVariant>
#include "../logging/LoggingCategories.h"

CategoryRepository::CategoryRepository(QSqlDatabase db): m_db(db) {}

std::vector<Category> CategoryRepository::getAllCategories()
{
    std::vector<Category> categories;

    QSqlQuery query(m_db);
    query.prepare(R"(SELECT id, category FROM categories WHERE deleted_at IS NULL)");

    if (!query.exec()) {
        qCWarning(logDatabase) << "getAllCategories failed:" << query.lastError();
        return categories;
    }

    while (query.next()) {
        Category category;
        category.id = query.value("id").toInt();
        category.category = query.value("category").toString();

        categories.push_back(category);
    }

    return categories;
}

std::optional<Category> CategoryRepository::getCategoryById(int categoryId)
{
    QSqlQuery query(m_db);
    query.prepare(R"(SELECT id, category FROM categories WHERE id = :id
                AND deleted_at IS NULL)");
    query.bindValue(":id", categoryId);

    if (!query.exec()) {
        qCWarning(logDatabase) << "getCategoryById failed:" << query.lastError();
        return std::nullopt;
    }

    if (!query.next()) {
        return std::nullopt;
    }

    Category category;
    category.id = query.value("id").toInt();
    category.category = query.value("category").toString();

    return category;
}

void CategoryRepository::create(const Category &category)
{
    QSqlQuery query(m_db);
    query.prepare(R"(
        INSERT INTO categories (category)
        VALUES (:category)
    )");

    query.bindValue(":category", category.category);

    if (!query.exec()) {
        qCWarning(logDatabase) << "create failed:" << query.lastError();
    }
}

void CategoryRepository::update(const Category &category)
{
    QSqlQuery query(m_db);
    query.prepare(R"(
        UPDATE categories
        SET category = :category, updated_at = CURRENT_TIMESTAMP
        WHERE id = :category_id
    )");

    query.bindValue(":category_id", category.id);
    query.bindValue(":category", category.category);

    if (!query.exec()) {
        qCWarning(logDatabase) << "update failed:" << query.lastError();
    }
}

bool CategoryRepository::remove(const Category &category)
{
    QSqlQuery query(m_db);
    query.prepare(R"(
        UPDATE categories
        SET deleted_at = CURRENT_TIMESTAMP
        WHERE id = :category_id
    )");

    query.bindValue(":category_id", category.id);

    if (!query.exec()) {
        qCWarning(logDatabase) << "remove failed:" << query.lastError();
        return false;
    }

    return true;
}
