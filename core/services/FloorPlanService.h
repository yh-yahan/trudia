#ifndef FLOORPLANSERVICE_H
#define FLOORPLANSERVICE_H

#include <QObject>
#include "../data/FloorRepository.h"
#include "../data/CanvasItemRepository.h"
#include "../data/TableRepository.h"

class FloorModel;
class CanvasItemModel;

class FloorPlanService : public QObject
{
    Q_OBJECT

    Q_PROPERTY(FloorModel *floorModel READ floorModel CONSTANT)
    Q_PROPERTY(CanvasItemModel *canvasModel READ canvasModel CONSTANT)

public:
    FloorPlanService(FloorRepository &floorRepo,
                     CanvasItemRepository &canvasItemRepo,
                     TableRepository &tableRepo);

    FloorModel *floorModel() const;
    CanvasItemModel *canvasModel() const;

    Q_INVOKABLE void loadFloors();
    Q_INVOKABLE int createFloor(const QString &name);
    Q_INVOKABLE bool updateFloor(const Floor &floor);
    Q_INVOKABLE bool deleteFloor(int floorId);

    Q_INVOKABLE void loadCanvas(int floorId);
    Q_INVOKABLE bool saveCanvas(int floorId);
    Q_INVOKABLE void clearCanvas();

    Q_INVOKABLE void addItem(const QVariantMap &itemData);
    Q_INVOKABLE void createTableItem(const QVariantMap &itemData);
    Q_INVOKABLE void deleteItem(int index);

private:
    FloorModel *m_floorModel;
    CanvasItemModel *m_canvasModel;

    FloorRepository &m_floorRepo;
    CanvasItemRepository &m_canvasItemRepo;
    TableRepository &m_tableRepo;
};

#endif // FLOORPLANSERVICE_H
