#ifndef FLOORPLANSERVICE_H
#define FLOORPLANSERVICE_H

#include <QObject>
#include "../data/FloorRepository.h"
#include "../data/CanvasItemRepository.h"
#include "../data/TableRepository.h"
#include "../data/ReservationRepository.h"
#include "./TableService.h"

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
                     TableRepository &tableRepo,
                     ReservationRepository &reservationRepo,
                     TableService &tableService);

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

signals:
    void tableStatusUpdated(int tableId, const QString &status);

public slots:
    void onTableStatusChanged(int tableId, const QString &newStatus);

private:
    FloorModel *m_floorModel;
    CanvasItemModel *m_canvasModel;

    FloorRepository &m_floorRepo;
    CanvasItemRepository &m_canvasItemRepo;
    ReservationRepository &m_reservationRepo;
    TableRepository &m_tableRepo;
    TableService &m_tableService;
};

#endif // FLOORPLANSERVICE_H
