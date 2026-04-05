#ifndef CATEGORYMODEL_H
#define CATEGORYMODEL_H

#include <QAbstractListModel>
#include <QVector>
#include "../data/CategoryRepository.h"

class CategoryModel : public QAbstractListModel
{
    Q_OBJECT

public:
    enum Roles {
        IdRole = Qt::UserRole + 1,
        NameRole
    };

    explicit CategoryModel(CategoryRepository &repo, QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    void reload();
    void clear();

private:
    CategoryRepository &m_repo;
    QVector<Category> m_data;
};

#endif // CATEGORYMODEL_H
