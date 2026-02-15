#include "RestaurantRepository.h"

#include <QSqlQuery>
#include <QSqlError>
#include <QVariant>
#include <QDebug>

RestaurantRepository::RestaurantRepository(QSqlDatabase db): m_db(db) {}

std::optional<Restaurant> RestaurantRepository::get()
{
    QSqlQuery query(m_db);
    query.prepare(R"(
        SELECT id, name, address, phone_number, email, website
        FROM restaurant
        ORDER BY id ASC
        LIMIT 1
    )");

    if (!query.exec()) {
        qWarning() << "Failed to fetch restaurant:"
                   << query.lastError().text();
        return std::nullopt;
    }

    if (!query.next()) {
        return std::nullopt;
    }

    Restaurant restaurant;
    restaurant.id = query.value("id").toInt();
    restaurant.name = query.value("name").toString();
    restaurant.address = query.value("address").toString();

    if (!query.value("phone_number").isNull())
        restaurant.phone_number = query.value("phone_number").toString();

    if (!query.value("email").isNull())
        restaurant.email = query.value("email").toString();

    if (!query.value("website").isNull())
        restaurant.website = query.value("website").toString();

    return restaurant;
}

void RestaurantRepository::save(const Restaurant &restaurant)
{
    QSqlQuery query(m_db);

    if (restaurant.id == -1) {
        query.prepare(R"(
            INSERT INTO restaurant (name, address, phone_number, email, website)
            VALUES (:name, :address, :phone_number, :email, :website)
        )");
    } else {
        query.prepare(R"(
            UPDATE restaurant
            SET name = :name,
                address = :address,
                phone_number = :phone_number,
                email = :email,
                website = :website
            WHERE id = :id
        )");
        query.bindValue(":id", restaurant.id);
    }

    query.bindValue(":name", restaurant.name);
    query.bindValue(":address", restaurant.address);

    query.bindValue(":phone_number",
                    restaurant.phone_number.has_value()
                        ? QVariant(*restaurant.phone_number)
                        : QVariant());

    query.bindValue(":email",
                    restaurant.email.has_value()
                        ? QVariant(*restaurant.email)
                        : QVariant());

    query.bindValue(":website",
                    restaurant.website.has_value()
                        ? QVariant(*restaurant.website)
                        : QVariant());

    if (!query.exec()) {
        qWarning() << "Failed to save restaurant:"
                   << query.lastError().text();
        return;
    }

    if (restaurant.id == -1) {
        qDebug() << "Inserted restaurant with id:"
                 << query.lastInsertId().toInt();
    }
}
