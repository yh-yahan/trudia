#ifndef CATEGORYREPOSITORY_H
#define CATEGORYREPOSITORY_H

#include <QString>
#include <QSqlDatabase>
#include "../domain/Category.h"

class CategoryRepository
{
public:
    explicit CategoryRepository(QSqlDatabase db);

    std::vector<Category> getAllCategories();
    std::optional<Category> getCategoryById(int categoryId);
    void create(const Category &category);
    void update(const Category &category);
    void remove(const Category &category);

private:
    QSqlDatabase m_db;
};

#endif // CATEGORYREPOSITORY_H
