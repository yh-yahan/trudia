#ifndef CANVASITEM_H
#define CANVASITEM_H

#include <QString>
#include <optional>
#include "../enums/TableStatus.h"

struct CanvasItem {
    int id = -1;
    int floor_id;
    std::optional<int> table_id;
    QString type;
    std::optional<QString> label;
    double x;
    double y;
    double width;
    double height;
    double rotation;
    QString color;
    QString border_color;
    double border_width;
    double opacity;
    int z_order;
    std::optional<QString> metadata;

    std::optional<int> capacity;
    std::optional<TableStatus> status;
};

#endif // CANVASITEM_H
