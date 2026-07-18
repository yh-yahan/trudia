#include "FloorRepository.h"

#include <QSqlQuery>
#include <QSqlError>
#include <QVariant>
#include "../logging/LoggingCategories.h"

FloorRepository::FloorRepository(QSqlDatabase db)
    : m_db(db) {}

std::vector<Floor> FloorRepository::getAll()
{
    std::vector<Floor> floors;

    QSqlQuery query(m_db);
    query.prepare(R"(
        SELECT id, name, floor_number, sort_order, is_active
        FROM floors
        ORDER BY sort_order ASC
    )");

    if (!query.exec()) {
        qCWarning(logDatabase) << "Failed to fetch floors:" << query.lastError();
        return floors;
    }

    while (query.next()) {
        Floor floor;

        floor.id = query.value("id").toInt();
        floor.name = query.value("name").toString();
        floor.floor_number = query.value("floor_number").toInt();
        floor.sort_order = query.value("sort_order").toInt();
        floor.is_active = query.value("is_active").toInt();

        floors.push_back(floor);
    }

    return floors;
}

Floor FloorRepository::getById(int id)
{
    QSqlQuery query(m_db);
    query.prepare(R"(
        SELECT id, name, floor_number, sort_order, is_active
        FROM floors
        WHERE id = :id
    )");

    query.bindValue(":id", id);

    if (!query.exec()) {
        qCWarning(logDatabase) << "Failed to fetch floor:" << query.lastError();
        return Floor{};
    }

    if (query.next()) {
        Floor floor;

        floor.id = query.value("id").toInt();
        floor.name = query.value("name").toString();
        floor.floor_number = query.value("floor_number").toInt();
        floor.sort_order = query.value("sort_order").toInt();
        floor.is_active = query.value("is_active").toInt();

        return floor;
    }

    return Floor{};
}

int FloorRepository::create(const Floor &floor)
{
    QSqlQuery query(m_db);

    query.prepare(R"(
        INSERT INTO floors (
            name,
            floor_number,
            sort_order,
            is_active
        )
        VALUES (
            :name,
            :floor_number,
            :sort_order,
            :is_active
        )
    )");

    query.bindValue(":name", floor.name);
    query.bindValue(":floor_number", floor.floor_number);
    query.bindValue(":sort_order", floor.sort_order);
    query.bindValue(":is_active", floor.is_active);

    if (!query.exec()) {
        qCWarning(logDatabase) << "Failed to create floor:" << query.lastError();
        return -1;
    }

    return query.lastInsertId().toInt();
}

bool FloorRepository::update(const Floor &floor)
{
    QSqlQuery query(m_db);

    query.prepare(R"(
        UPDATE floors SET
            name = :name,
            floor_number = :floor_number,
            sort_order = :sort_order,
            is_active = :is_active
        WHERE id = :id
    )");

    query.bindValue(":id", floor.id);
    query.bindValue(":name", floor.name);
    query.bindValue(":floor_number", floor.floor_number);
    query.bindValue(":sort_order", floor.sort_order);
    query.bindValue(":is_active", floor.is_active);

    return query.exec();
}

bool FloorRepository::remove(int id)
{
    QSqlQuery query(m_db);

    query.prepare(R"(
        DELETE FROM floors
        WHERE id = :id
    )");

    query.bindValue(":id", id);

    return query.exec();
}
