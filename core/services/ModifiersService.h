#ifndef MODIFIERSSERVICE_H
#define MODIFIERSSERVICE_H

#include <QObject>
#include <QVariant>
#include <QVariantList>
#include <QVariantMap>
#include <optional>
#include <vector>

#include "../data/ModifiersRepository.h"
#include "../data/RecipeComponentRepository.h"
#include "../database/DatabaseManager.h"

class ModifiersModel;

class ModifiersService : public QObject
{
    Q_OBJECT

    Q_PROPERTY(ModifiersModel *modifierModel READ modifierModel CONSTANT)
    Q_PROPERTY(ModifiersModel *menuModifierModel READ menuModifierModel CONSTANT)
    Q_PROPERTY(int currentMenuId READ currentMenuId WRITE setCurrentMenuId NOTIFY currentMenuIdChanged)

public:
    explicit ModifiersService(
        ModifiersRepository &repository, 
        RecipeComponentRepository &recipeComponentRepo,
        DatabaseManager &databaseManager,
        QObject *parent = nullptr);
    ~ModifiersService() override;

    ModifiersModel *modifierModel() const;
    ModifiersModel *menuModifierModel() const;

    int currentMenuId() const;
    void setCurrentMenuId(int menuId);

    std::vector<ModifierGroup> groups() const;
    std::optional<ModifierGroup> group(int id) const;
    std::vector<Modifier> modifiers(int groupId) const;
    std::vector<ModifierGroup> groupsForMenu(int menuId) const;

    Q_INVOKABLE QVariantMap getGroup(int id) const;
    Q_INVOKABLE QVariantList getModifiers(int groupId) const;

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

    Q_INVOKABLE bool attachGroupToMenu(int menuId, int groupId, int sortOrder = -1);
    Q_INVOKABLE bool detachGroupFromMenu(int menuId, int groupId);

    Q_INVOKABLE void reload();
    Q_INVOKABLE void reloadForMenu(int menuId);

signals:
    void groupsChanged();
    void modifiersChanged(int groupId);
    void menuGroupsChanged(int menuId);
    void currentMenuIdChanged();
    void errorOccurred(const QString &message);

private:
    bool isValidSelectionType(const QString &selectionType) const;
    bool isValidGroup(const QString &name,
                      const QString &selectionType,
                      int minSelect,
                      const std::optional<int> &maxSelect,
                      bool isRequired);
    bool isValidModifier(int groupId, const QString &name);

    std::optional<int> toOptionalMax(const QVariant &maxSelect) const;
    QVariantMap groupToMap(const ModifierGroup &group) const;
    QVariantMap modifierToMap(const Modifier &modifier) const;
    int nextModifierSortOrder(int groupId) const;
    int nextMenuGroupSortOrder(int menuId) const;

    ModifiersRepository &m_modifiersRepo;
    RecipeComponentRepository &m_recipeComponentRepo;
    DatabaseManager &m_databaseManager;

    ModifiersModel *m_modifierModel = nullptr;
    ModifiersModel *m_menuModifierModel = nullptr;
    int m_currentMenuId = -1;
};

#endif // MODIFIERSSERVICE_H
