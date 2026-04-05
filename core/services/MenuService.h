#ifndef MENUSERVICE_H
#define MENUSERVICE_H

#include <QObject>
#include <QString>
#include <QVariantList>
#include <QVariantMap>
#include "../data/MenuRepository.h"
#include "../data/CategoryRepository.h"

class CategoryModel;
class MenuItemModel;

class MenuService : public QObject
{
    Q_OBJECT
public:
    explicit MenuService(MenuRepository &menuRepo, 
                         CategoryRepository &categoryRepo,
                         QObject *parent = nullptr);

    Q_PROPERTY(CategoryModel* categoryModel READ categoryModel CONSTANT)
    Q_PROPERTY(MenuItemModel* menuItemModel READ menuItemModel NOTIFY menuItemsChanged)

    CategoryModel* categoryModel() const;
    MenuItemModel* menuItemModel() const;

    Q_INVOKABLE void setCurrentCategory(int categoryId);

    Q_INVOKABLE bool addCategory(const QString &categoryName);
    Q_INVOKABLE bool renameCategory(const int &categoryId, const QString &newName);
    Q_INVOKABLE bool removeCategory(const int &categoryId);

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

signals:
    void menuItemsChanged();

private:
    CategoryRepository &m_categoryRepo;
    MenuRepository &m_menuRepo;

    CategoryModel *m_categoryModel;
    MenuItemModel *m_menuItemModel;

    int m_currentCategoryId = -1;
};

#endif // MENUSERVICE_H
