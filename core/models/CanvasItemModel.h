#ifndef CANVASITEMMODEL_H
#define CANVASITEMMODEL_H

#include <QAbstractListModel>
#include "../domain/CanvasItem.h"

class CanvasItemModel : public QAbstractListModel
{
    Q_OBJECT

public:
    enum Roles {
        IdRole = Qt::UserRole + 1,
        TableIdRole,
        TypeRole,
        LabelRole,
        XRole,
        YRole,
        WidthRole,
        HeightRole,
        RotationRole,
        ColorRole,
        BorderColorRole,
        BorderWidthRole,
        OpacityRole,
        ZOrderRole,
        MetadataRole
    };

    explicit CanvasItemModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex& parent = QModelIndex()) const override;
    QVariant data(const QModelIndex& index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE QVariantMap get(int index) const;

    Q_INVOKABLE void setItems(const std::vector<CanvasItem>& items);
    Q_INVOKABLE std::vector<CanvasItem> items() const;

    Q_INVOKABLE void addItem(const CanvasItem& item);
    Q_INVOKABLE void updateItem(int index, const CanvasItem& item);
    Qt::ItemFlags flags(const QModelIndex &index) const override;
    bool setData(const QModelIndex &index, const QVariant &value, int role = Qt::EditRole) override;
    Q_INVOKABLE void removeItem(int index);
    void clear();

private:
    std::vector<CanvasItem> m_items;
};

#endif // CANVASITEMMODEL_H
