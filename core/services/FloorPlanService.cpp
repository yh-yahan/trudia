#include "FloorPlanService.h"

#include "../models/FloorModel.h"
#include "../models/CanvasItemModel.h"

FloorPlanService::FloorPlanService(FloorRepository &floorRepo,
                                   CanvasItemRepository &canvasItemRepo)
    : QObject(nullptr),
      m_floorRepo(floorRepo),
      m_canvasItemRepo(canvasItemRepo)
{
    m_floorModel = new FloorModel(this);
    m_canvasModel = new CanvasItemModel(this);
}

FloorModel *FloorPlanService::floorModel() const
{
    return m_floorModel;
}

CanvasItemModel *FloorPlanService::canvasModel() const
{
    return m_canvasModel;
}

void FloorPlanService::loadFloors()
{
    std::vector<Floor> floors = m_floorRepo.getAll();
    m_floorModel->setFloors(floors);
}

void FloorPlanService::loadCanvas(int floorId)
{
    std::vector<CanvasItem> items =
        m_canvasItemRepo.getByFloorId(floorId);

    m_canvasModel->setItems(items);
}

int FloorPlanService::createFloor(const QString &name,
                                 int floorNumber,
                                 int sortOrder)
{
    Floor floor;
    floor.name = name;
    floor.floor_number = floorNumber;
    floor.sort_order = sortOrder;
    floor.is_active = 1;

    int id = m_floorRepo.create(floor);

    if (id <= 0)
        return -1;

    floor.id = id;

    m_floorModel->addFloor(floor);

    return id;
}

bool FloorPlanService::updateFloor(const Floor &floor)
{
    bool ok = m_floorRepo.update(floor);

    if (!ok)
        return false;

    auto floors = m_floorModel->floors();

    for (int i = 0; i < static_cast<int>(floors.size()); i++) {
        if (floors[i].id == floor.id) {
            m_floorModel->updateFloor(i, floor);
            break;
        }
    }

    return true;
}

bool FloorPlanService::deleteFloor(int floorId)
{
    bool ok = m_floorRepo.remove(floorId);

    if (!ok)
        return false;

    auto floors = m_floorModel->floors();

    for (int i = 0; i < static_cast<int>(floors.size()); i++) {
        if (floors[i].id == floorId) {
            m_floorModel->removeFloor(i);
            break;
        }
    }

    return true;
}

bool FloorPlanService::saveCanvas(int floorId)
{
    std::vector<CanvasItem> items = m_canvasModel->items();

    return m_canvasItemRepo.saveAll(floorId, items);
}
