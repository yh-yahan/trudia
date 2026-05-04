#ifndef CANVASITEMREPOSITORY_H
#define CANVASITEMREPOSITORY_H

#include <vector>
#include <QSqlDatabase>
#include "../domain/CanvasItem.h"

class CanvasItemRepository
{
public:
    explicit CanvasItemRepository(QSqlDatabase db);

    std::vector<CanvasItem> getByFloorId(int floorId);

    bool saveAll(int floorId, const std::vector<CanvasItem> &items);
    bool remove(int id);

private:
    QSqlDatabase m_db;
};

#endif // CANVASITEMREPOSITORY_H
