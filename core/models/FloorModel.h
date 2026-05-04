#ifndef FLOORMODEL_H
#define FLOORMODEL_H

#include <QAbstractListModel>
#include <vector>
#include "../domain/Floor.h"

class FloorModel : public QAbstractListModel
{
    Q_OBJECT

public:
    enum Roles {
        IdRole = Qt::UserRole + 1,
        NameRole,
        FloorNumberRole,
        SortOrderRole,
        IsActiveRole
    };

    explicit FloorModel(QObject* parent = nullptr);

    int rowCount(const QModelIndex& parent = QModelIndex()) const override;
    QVariant data(const QModelIndex& index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE void setFloors(const std::vector<Floor>& floors);
    Q_INVOKABLE std::vector<Floor> floors() const;

    Q_INVOKABLE Floor getFloor(int index) const;

    Q_INVOKABLE void addFloor(const Floor& floor);
    Q_INVOKABLE void updateFloor(int index, const Floor& floor);
    Q_INVOKABLE void removeFloor(int index);

private:
    std::vector<Floor> m_floors;
};

#endif // FLOORMODEL_H
