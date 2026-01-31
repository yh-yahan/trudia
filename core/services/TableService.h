#ifndef TABLESERVICE_H
#define TABLESERVICE_H

#include <QObject>
#include <QString>
#include <QVariantList>
#include <QVariantMap>
#include "../data/TableRepository.h"

class TableService : public QObject
{
    Q_OBJECT
public:
    explicit TableService(TableRepository &tableRepo);

    Q_INVOKABLE QVariantList getAllTables() const;
    Q_INVOKABLE bool addTable(const QString &tableName, const int capacity);
    Q_INVOKABLE bool editTable(const int &tableId,
                               const QString &tableName,
                               const int capacity);
    Q_INVOKABLE bool removeTable(const int &tableId);

private:
    TableRepository &m_tableRepo;
};

#endif // TABLESERVICE_H
