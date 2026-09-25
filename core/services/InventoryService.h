#ifndef INVENTORYSERVICE_H
#define INVENTORYSERVICE_H

#include <QObject>
#include <QVariantList>
#include <QVariantMap>

#include "../data/InventoryItemRepository.h"
#include "../data/RecipeComponentRepository.h"

class InventoryService : public QObject
{
    Q_OBJECT

public:
    explicit InventoryService(InventoryItemRepository inventoryItemRepo,
                              RecipeComponentRepository recipeComponentRepo,
                              QObject *parent = nullptr);

    Q_INVOKABLE QVariantList getItems() const;
    Q_INVOKABLE QVariantMap getItem(int id) const;
    Q_INVOKABLE int createItem(const QVariantMap &data);
    Q_INVOKABLE bool updateItem(int id, const QVariantMap &data);
    Q_INVOKABLE bool removeItem(int id);

    Q_INVOKABLE QVariantList getRecipeComponents(const QString &ownerType, int ownerId) const;
    Q_INVOKABLE QVariantMap getRecipeComponent(int id) const;
    Q_INVOKABLE int createRecipeComponent(const QVariantMap &data);
    Q_INVOKABLE bool updateRecipeComponent(int id, const QVariantMap &data);
    Q_INVOKABLE bool removeRecipeComponent(int id);

private:
    InventoryItemRepository m_inventoryItemRepo;
    RecipeComponentRepository m_recipeComponentRepo;

    QVariantMap toMap(const InventoryItem &item) const;
    std::optional<InventoryItem> fromMap(const QVariantMap &data) const;

    QVariantMap toMap(const RecipeComponent &row) const;
    std::optional<RecipeComponent> fromRecipeMap(const QVariantMap &data) const;
};

#endif // INVENTORYSERVICE_H
