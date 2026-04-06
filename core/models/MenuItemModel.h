#ifndef MENUITEMMODEL_H
#define MENUITEMMODEL_H

#include <QAbstractListModel>
#include <QVector>
#include "../domain/Menu.h"
#include "../data/MenuRepository.h"

class MenuItemModel : public QAbstractListModel
{
    Q_OBJECT

public:
    enum Roles {
        IdRole = Qt::UserRole + 1,
        ItemRole,
        PriceRole,
        CategoryIdRole,
        PortionRole,
        AvailableRole,
        TaxableRole
    };

    explicit MenuItemModel(MenuRepository &repo, QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    void setCategory(int categoryId);
    void reload(int categoryId);
    void clear();

private:
    MenuRepository &m_repo;
    QVector<Menu> m_data;
    int m_currentCategoryId = -1;
};

#endif // MENUITEMMODEL_H
