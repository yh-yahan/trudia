#ifndef MENUREPOSITORY_H
#define MENUREPOSITORY_H

#include <QString>
#include <QSqlDatabase>
#include "../domain/Menu.h"

class MenuRepository
{
public:
    explicit MenuRepository(QSqlDatabase db);

    std::vector<Menu> getAllMenuItems();
    std::optional<Menu> getMenuItemById(int menuId);
    std::vector<Menu> getMenuItemsByCategory(int categoryId);
    void create(const Menu &menu);
    void update(const Menu &menu);
    bool remove(const Menu &menu);

private:
    QSqlDatabase m_db;
};

#endif // MENUREPOSITORY_H
