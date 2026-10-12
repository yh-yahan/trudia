#ifndef MENUSERVICE_H
#define MENUSERVICE_H

#include <QObject>
#include <QString>
#include <QVariantList>
#include <QVariantMap>
#include "../data/MenuRepository.h"
#include "../data/CategoryRepository.h"
#include "../database/DatabaseManager.h"

class CategoryModel;
class MenuItemModel;

class MenuService : public QObject
{
    Q_OBJECT
public:
    explicit MenuService(MenuRepository &menuRepo, 
                         CategoryRepository &categoryRepo,
                         DatabaseManager &databaseManager,
                         QObject *parent = nullptr);

    Q_PROPERTY(CategoryModel* categoryModel READ categoryModel CONSTANT)
    Q_PROPERTY(MenuItemModel* menuItemModel READ menuItemModel NOTIFY menuItemsChanged)
    Q_PROPERTY(int currentCategoryId READ currentCategoryId WRITE setCurrentCategoryId NOTIFY currentCategoryIdChanged)

    CategoryModel* categoryModel() const;
    MenuItemModel* menuItemModel() const;

    int currentCategoryId() const;

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

public slots:
    void setCurrentCategoryId(int categoryId);

signals:
    void menuItemsChanged();
    void currentCategoryIdChanged();

private:
    CategoryRepository &m_categoryRepo;
    MenuRepository &m_menuRepo;
    DatabaseManager &m_databaseManager;

    CategoryModel *m_categoryModel;
    MenuItemModel *m_menuItemModel;

    int m_currentCategoryId = -1;
};

#endif // MENUSERVICE_H
