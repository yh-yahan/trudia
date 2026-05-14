#ifndef TABLEMODEL_H
#define TABLEMODEL_H

#include <QAbstractListModel>
#include <QVector>
#include "../domain/Table.h"
#include "../data/TableRepository.h"

class TableModel : public QAbstractListModel
{
    Q_OBJECT

public:
    enum Roles {
        IdRole = Qt::UserRole + 1,
        NameRole,
        CapacityRole,
        StatusRole
    };

    explicit TableModel(TableRepository &repo, QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    void reload();
    void clear();

private:
    TableRepository &m_repo;
    QVector<Table> m_data;
};

#endif // TABLEMODEL_H
