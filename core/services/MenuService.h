#ifndef MENUSERVICE_H
#define MENUSERVICE_H

#include <QObject>
#include <optional>
#include <QString>
#include <QVariantList>
#include <QVariantMap>
#include "../data/MenuRepository.h"
#include "../data/CategoryRepository.h"

class MenuService : public QObject
{
    Q_OBJECT
public:
    explicit MenuService(MenuRepository &menuRepo, CategoryRepository &categoryRepo);

    Q_INVOKABLE QVariantList getAllCategory() const;
    Q_INVOKABLE bool addCategory(const QString &categoryName);
    Q_INVOKABLE bool renameCategory(const int &categoryId, const QString &newName);
    Q_INVOKABLE bool removeCategory(const int &categoryId);

    Q_INVOKABLE QVariantList getAllMenuItems() const;
    Q_INVOKABLE QVariantList getMenuItemsByCategory(int categoryId) const;
    Q_INVOKABLE bool addMenuItem(const QString &itemName,
                    const int &categoryId,
                    const double &price,
                    const bool &isAvailable,
                    const bool &isTaxable,
                    const QString &portionSize = QString());
    Q_INVOKABLE bool editMenuItem(const int &menuItemId,
                     const QString &itemName,
                     const int &categoryId,
                     const double &price,
                     const bool &isAvailable,
                     const bool &isTaxable,
                     const QString &portionSize = QString());
    Q_INVOKABLE bool removeMenuItem(const int &menuItemId);

private:
    CategoryRepository &m_categoryRepo;
    MenuRepository &m_menuRepo;
};

#endif // MENUSERVICE_H
