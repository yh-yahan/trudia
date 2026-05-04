#ifndef FLOORREPOSITORY_H
#define FLOORREPOSITORY_H

#include <vector>
#include <QSqlDatabase>
#include "../domain/Floor.h"

class FloorRepository
{
public:
    explicit FloorRepository(QSqlDatabase db);

    std::vector<Floor> getAll();
    Floor getById(int id);

    int create(const Floor &floor);
    bool update(const Floor &floor);
    bool remove(int id);

private:
    QSqlDatabase m_db;
};

#endif // FLOORREPOSITORY_H
