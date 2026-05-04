#ifndef FLOORPLANSERVICE_H
#define FLOORPLANSERVICE_H

#include <QObject>
#include "../data/FloorRepository.h"
#include "../data/CanvasItemRepository.h"

class FloorModel;
class CanvasItemModel;

class FloorPlanService : public QObject
{
    Q_OBJECT

    Q_PROPERTY(FloorModel *floorModel READ floorModel CONSTANT)
    Q_PROPERTY(CanvasItemModel *canvasModel READ canvasModel CONSTANT)

public:
    FloorPlanService(FloorRepository &floorRepo,
                     CanvasItemRepository &canvasItemRepo);

    FloorModel *floorModel() const;
    CanvasItemModel *canvasModel() const;

    Q_INVOKABLE void loadFloors();
    Q_INVOKABLE int createFloor(const QString& name,
                            int floorNumber,
                            int sortOrder);
    Q_INVOKABLE bool updateFloor(const Floor& floor);
    Q_INVOKABLE bool deleteFloor(int floorId);

    Q_INVOKABLE void loadCanvas(int floorId);
    Q_INVOKABLE bool saveCanvas(int floorId);

private:
    FloorModel *m_floorModel;
    CanvasItemModel *m_canvasModel;

    FloorRepository &m_floorRepo;
    CanvasItemRepository &m_canvasItemRepo;
};

#endif // FLOORPLANSERVICE_H
