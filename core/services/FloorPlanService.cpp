#include "FloorPlanService.h"

#include "../models/FloorModel.h"
#include "../models/CanvasItemModel.h"

FloorPlanService::FloorPlanService(FloorRepository &floorRepo,
                                   CanvasItemRepository &canvasItemRepo,
                                   TableRepository &tableRepo)
    : QObject(nullptr),
      m_floorRepo(floorRepo),
      m_canvasItemRepo(canvasItemRepo),
      m_tableRepo(tableRepo)
{
    m_floorModel = new FloorModel(this);
    m_canvasModel = new CanvasItemModel(this);

    loadFloors();
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

    for (CanvasItem &item : items)
    {
        if (item.type == "table" && item.table_id.has_value())
        {
            const int tableId = item.table_id.value();

            auto tableOpt = m_tableRepo.getTableById(tableId);

            if (!tableOpt) {
                return;
            }

            const Table &table = *tableOpt;

            item.capacity = table.capacity;
            item.label = table.table_name;
        }
        else
        {
            item.capacity.reset();
        }
    }

    m_canvasModel->setItems(items);
}

int FloorPlanService::createFloor(const QString &name)
{
    Floor floor;

    floor.name = name;

    int nextNumber = m_floorModel->rowCount() + 1;

    floor.floor_number = nextNumber;
    floor.sort_order = nextNumber;

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

void FloorPlanService::addItem(const QVariantMap &itemData)
{
    CanvasItem item;

    item.id = -1;
    item.type = itemData.value("type").toString();
    item.x = itemData.value("x").toDouble();
    item.y = itemData.value("y").toDouble();
    if (itemData.contains("table_id") && !itemData.value("table_id").isNull())
    {
        item.table_id = itemData.value("table_id").toInt();
    }
    item.width = itemData.value("width").toDouble();
    item.height = itemData.value("height").toDouble();
    item.rotation = itemData.value("rotation", 0).toDouble();
    item.label = itemData.value("label").toString();
    item.color = itemData.value("color", "#444").toString();
    item.border_color = itemData.value("border_color", "#ffffff").toString();
    item.opacity = itemData.value("opacity", 1.0).toDouble();
    item.z_order = itemData.value("z_order", 0).toInt();
    item.metadata = itemData.contains("metadata")
        ? std::optional<QString>(itemData.value("metadata").toString())
        : std::nullopt;

    m_canvasModel->addItem(item);
}

void FloorPlanService::createTableItem(const QVariantMap &itemData, int capacity)
{
    const int floorId = itemData.value("floor_id").toInt();
    const QString label = itemData.value("label").toString().trimmed();

    Table table;
    table.table_name = label;
    table.capacity = capacity;
    table.status = "available";

    const int tableId = m_tableRepo.create(table);

    CanvasItem item;
    item.id = -1;
    item.floor_id = floorId;
    item.table_id = tableId;
    item.type = "table";

    item.x = itemData.value("x").toDouble();
    item.y = itemData.value("y").toDouble();
    item.width = itemData.value("width").toDouble();
    item.height = itemData.value("height").toDouble();
    item.rotation = itemData.value("rotation", 0).toDouble();

    item.label = label;

    item.color = itemData.value("color", "#444").toString();
    item.border_color = itemData.value("border_color", "#ffffff").toString();
    item.border_width = itemData.value("border_width", 1.0).toDouble();
    item.opacity = itemData.value("opacity", 1.0).toDouble();
    item.z_order = itemData.value("z_order", 0).toInt();

    if (itemData.contains("metadata") && !itemData.value("metadata").isNull()) {
        item.metadata = itemData.value("metadata").toString();
    }

    m_canvasModel->addItem(item);
}

void FloorPlanService::deleteItem(int index)
{
    m_canvasModel->removeItem(index);
}
