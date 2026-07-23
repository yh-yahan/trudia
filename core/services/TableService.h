#ifndef TABLESERVICE_H
#define TABLESERVICE_H

#include <QObject>
#include <QString>
#include <QVariantList>
#include <QVariantMap>
#include "../data/TableRepository.h"

class TableModel;

class TableService : public QObject
{
    Q_OBJECT

    Q_PROPERTY(TableModel* tableModel READ tableModel CONSTANT)

public:
    explicit TableService(TableRepository &tableRepo,
                          QObject *parent = nullptr);

    TableModel* tableModel() const;

    Q_INVOKABLE int addTable(const QString &tableName, const int capacity);
    Q_INVOKABLE bool editTable(const int &tableId,
                               const QString &tableName,
                               const int capacity);
    Q_INVOKABLE bool removeTable(const int &tableId);
    Q_INVOKABLE bool setTableStatus(const int &tableId,
                                const QString &status);

signals:
    void tablesChanged();
    void tableStatusChanged(int tableId, const QString &status);

private:
    TableRepository &m_tableRepo;
    TableModel *m_tableModel;
};

#endif // TABLESERVICE_H
