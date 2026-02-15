#ifndef RESTAURANTREPOSITORY_H
#define RESTAURANTREPOSITORY_H

#include <QString>
#include <QSqlDatabase>
#include "../domain/Restaurant.h"

class RestaurantRepository
{
public:
    explicit RestaurantRepository(QSqlDatabase db);

    std::optional<Restaurant> get();
    void save(const Restaurant &setting);

private:
    QSqlDatabase m_db;
};

#endif // RESTAURANTREPOSITORY_H
