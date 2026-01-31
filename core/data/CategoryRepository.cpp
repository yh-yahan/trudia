#include "CategoryRepository.h"

#include <QSqlQuery>
#include <QSqlError>
#include <QVariant>
#include <QDebug>

CategoryRepository::CategoryRepository(QSqlDatabase db): m_db(db) {}

std::vector<Category> CategoryRepository::getAllCategories()
{
    std::vector<Category> categories;

    QSqlQuery query(m_db);
    query.prepare("SELECT id, category FROM categories");

    if (!query.exec()) {
        qWarning() << "getAllCategories failed:" << query.lastError();
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
    query.prepare("SELECT id, category FROM categories WHERE id = :id");
    query.bindValue(":id", categoryId);

    if (!query.exec()) {
        qWarning() << "getCategoryById failed:" << query.lastError();
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
        qWarning() << "create failed:" << query.lastError();
    }
}

void CategoryRepository::update(const Category &category)
{
    QSqlQuery query(m_db);
    query.prepare(R"(
        UPDATE categories
        SET category = :category
        WHERE id = :category_id
    )");

    query.bindValue(":category_id", category.id);
    query.bindValue(":category", category.category);

    if (!query.exec()) {
        qWarning() << "update failed:" << query.lastError();
    }
}

void CategoryRepository::remove(const Category &category)
{
    QSqlQuery query(m_db);
    query.prepare(R"(
        DELETE FROM categories
        WHERE id = :category_id
    )");

    query.bindValue(":category_id", category.id);

    if (!query.exec()) {
        qWarning() << "remove failed:" << query.lastError();
    }
}
