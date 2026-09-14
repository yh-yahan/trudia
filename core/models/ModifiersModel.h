#ifndef MODIFIERSMODEL_H
#define MODIFIERSMODEL_H

#include "../data/ModifiersRepository.h"

#include <QAbstractListModel>
#include <QVariantList>
#include <QVariantMap>
#include <vector>

class ModifiersService;

class ModifiersModel : public QAbstractListModel
{
    Q_OBJECT

public:
    enum Roles {
        IdRole = Qt::UserRole + 1,
        NameRole,
        SelectionTypeRole,
        MinSelectRole,
        MaxSelectRole,
        IsRequiredRole,
        CreatedAtRole,
        ModifiersRole
    };
    Q_ENUM(Roles)

    explicit ModifiersModel(ModifiersService &service, QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE void loadGroups();
    Q_INVOKABLE void loadGroupsForMenu(int menuId);

    Q_INVOKABLE QVariantMap getGroup(int id) const;

    Q_INVOKABLE int createGroup(const QString &name,
                                const QString &selectionType,
                                int minSelect,
                                const QVariant &maxSelect,
                                bool isRequired);
    Q_INVOKABLE bool updateGroup(int id,
                                 const QString &name,
                                 const QString &selectionType,
                                 int minSelect,
                                 const QVariant &maxSelect,
                                 bool isRequired);
    Q_INVOKABLE bool deleteGroup(int id);

    Q_INVOKABLE int createModifier(int groupId,
                                   const QString &name,
                                   int priceDelta,
                                   bool isDefault = false,
                                   bool isAvailable = true,
                                   int sortOrder = -1);
    Q_INVOKABLE bool updateModifier(int id,
                                    const QString &name,
                                    int priceDelta,
                                    bool isDefault,
                                    bool isAvailable,
                                    int sortOrder);
    Q_INVOKABLE bool deleteModifier(int id);

private:
    QVariantMap groupToMap(const ModifierGroup &group) const;
    QVariantMap modifierToMap(const Modifier &modifier) const;
    QVariantList modifiersToList(int groupId) const;
    const ModifierGroup *findGroup(int id) const;

    ModifiersService &m_service;
    std::vector<ModifierGroup> m_groups;
    int m_menuId = -1;
    bool m_forMenu = false;
};

#endif
