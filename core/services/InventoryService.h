#ifndef INVENTORYSERVICE_H
#define INVENTORYSERVICE_H

#include <QObject>
#include <QVariantList>
#include <QVariantMap>

#include "../data/InventoryItemRepository.h"

class InventoryService : public QObject
{
    Q_OBJECT

public:
    explicit InventoryService(InventoryItemRepository inventoryItemRepo,
                              QObject *parent = nullptr);

    Q_INVOKABLE QVariantList getItems() const;
    Q_INVOKABLE QVariantMap getItem(int id) const;

    Q_INVOKABLE int createItem(const QVariantMap &data);
    Q_INVOKABLE bool updateItem(int id, const QVariantMap &data);
    Q_INVOKABLE bool removeItem(int id);

private:
    QVariantMap toMap(const InventoryItem &item) const;
    std::optional<InventoryItem> fromMap(const QVariantMap &data) const;

    InventoryItemRepository m_inventoryItemRepo;
};

#endif // INVENTORYSERVICE_H
