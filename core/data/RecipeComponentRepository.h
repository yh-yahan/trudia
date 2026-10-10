#ifndef RECIPECOMPONENTREPOSITORY_H
#define RECIPECOMPONENTREPOSITORY_H

#include <QString>
#include <QSqlDatabase>
#include "../domain/inventory.h"

class RecipeComponentRepository
{
public:
    explicit RecipeComponentRepository(QSqlDatabase db);

    int create(const RecipeComponent &row);
    bool update(const RecipeComponent &row);
    bool remove(int id);

    std::optional<RecipeComponent> getById(int id) const;
    std::vector<RecipeComponent> listByOwner(RecipeComponentOwnerType ownerType, int ownerId) const;

    bool removeByModifier(int modifierId);
    bool removeByOwnerAndModifier(const QString &ownerType, int ownerId, int modifierId);

private:
    QSqlDatabase m_db;
};

#endif // RECIPECOMPONENTREPOSITORY_H
