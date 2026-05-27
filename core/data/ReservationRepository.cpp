#include "ReservationRepository.h"

#include <QSqlError>
#include <QSqlQuery>
#include <QVariant>
#include <QDebug>

ReservationRepository::ReservationRepository(QSqlDatabase db)
    : m_db(db) {}

Reservation ReservationRepository::mapQueryToReservation(const QSqlQuery &query)
{
    Reservation reservation;

    reservation.id =
        query.value("id").toInt();

    reservation.customerName =
        query.value("customer_name").toString();

    reservation.customerPhone =
        query.value("customer_phone").toString();

    reservation.pax =
        query.value("pax").toInt();

    reservation.tableId =
        query.value("table_id").toInt();

    reservation.reservationDateTime =
        QDateTime::fromString(
            query.value("reservation_datetime").toString(),
            "yyyy-MM-dd HH:mm:ss");

    reservation.durationMinutes =
        query.value("duration_minutes").toInt();

    reservation.status =
        query.value("status").toString();

    reservation.notes =
        query.value("notes").toString();

    return reservation;
}

bool ReservationRepository::createReservation(const Reservation &reservation)
{
    QSqlQuery query(m_db);

    query.prepare(R"(
        INSERT INTO reservations (
            customer_name,
            customer_phone,
            pax,
            table_id,
            reservation_datetime,
            duration_minutes,
            status,
            notes
        )
        VALUES (
            :customer_name,
            :customer_phone,
            :pax,
            :table_id,
            :reservation_datetime,
            :duration_minutes,
            :status,
            :notes
        )
    )");

    query.bindValue(
        ":customer_name",
        reservation.customerName);

    query.bindValue(
        ":customer_phone",
        reservation.customerPhone);

    query.bindValue(
        ":pax",
        reservation.pax);

    query.bindValue(
        ":table_id",
        reservation.tableId);

    query.bindValue(
        ":reservation_datetime",
        reservation.reservationDateTime.toString(
        "yyyy-MM-dd HH:mm:ss"));

    query.bindValue(
        ":duration_minutes",
        reservation.durationMinutes);

    query.bindValue(
        ":status",
        reservation.status);

    query.bindValue(
        ":notes",
        reservation.notes);

    if (!query.exec())
    {
        qWarning() << "Failed to create reservation:"
                   << query.lastError();

        return false;
    }

    return true;
}

bool ReservationRepository::updateReservation(
    const Reservation &reservation)
{
    QSqlQuery query(m_db);

    query.prepare(R"(
        UPDATE reservations
        SET
            customer_name = :customer_name,
            customer_phone = :customer_phone,
            pax = :pax,
            table_id = :table_id,
            reservation_datetime = :reservation_datetime,
            duration_minutes = :duration_minutes,
            status = :status,
            notes = :notes,
            updated_at = CURRENT_TIMESTAMP
        WHERE id = :id
    )");

    query.bindValue(
        ":id",
        reservation.id);

    query.bindValue(
        ":customer_name",
        reservation.customerName);

    query.bindValue(
        ":customer_phone",
        reservation.customerPhone);

    query.bindValue(
        ":pax",
        reservation.pax);

    query.bindValue(
        ":table_id",
        reservation.tableId);

    query.bindValue(
        ":reservation_datetime",
        reservation.reservationDateTime.toString(
        "yyyy-MM-dd HH:mm:ss"));

    query.bindValue(
        ":duration_minutes",
        reservation.durationMinutes);

    query.bindValue(
        ":status",
        reservation.status);

    query.bindValue(
        ":notes",
        reservation.notes);

    if (!query.exec())
    {
        qWarning() << "Failed to update reservation:"
                   << query.lastError();

        return false;
    }

    return true;
}

bool ReservationRepository::deleteReservation(
    int reservationId)
{
    QSqlQuery query(m_db);

    query.prepare(R"(
        DELETE FROM reservations
        WHERE id = :id
    )");

    query.bindValue(
        ":id",
        reservationId);

    if (!query.exec())
    {
        qWarning() << "Failed to delete reservation:"
                   << query.lastError();

        return false;
    }

    return true;
}

Reservation ReservationRepository::getReservationById(
    int reservationId)
{
    QSqlQuery query(m_db);

    query.prepare(R"(
        SELECT *
        FROM reservations
        WHERE id = :id
    )");

    query.bindValue(
        ":id",
        reservationId);

    if (!query.exec())
    {
        qWarning() << "Failed to get reservation:"
                   << query.lastError();

        return {};
    }

    if (!query.next())
        return {};

    return mapQueryToReservation(query);
}

QList<Reservation> ReservationRepository::getReservations()
{
    QList<Reservation> reservations;

    QSqlQuery query(m_db);

    query.prepare(R"(
        SELECT *
        FROM reservations
        ORDER BY reservation_datetime ASC
    )");

    if (!query.exec())
    {
        qWarning() << "Failed to get reservations:"
                   << query.lastError();

        return reservations;
    }

    while (query.next())
    {
        reservations.append(
            mapQueryToReservation(query));
    }

    return reservations;
}

QList<Reservation> ReservationRepository::getReservationsByDate(
    const QDate &date)
{
    QList<Reservation> reservations;

    QSqlQuery query(m_db);

    query.prepare(R"(
        SELECT *
        FROM reservations
        WHERE DATE(reservation_datetime) = :date
        ORDER BY reservation_datetime ASC
    )");

    query.bindValue(
        ":date",
        date.toString("yyyy-MM-dd"));

    if (!query.exec())
    {
        qWarning() << "Failed to get reservations by date:"
                   << query.lastError();

        return reservations;
    }

    while (query.next())
    {
        reservations.append(
            mapQueryToReservation(query));
    }

    return reservations;
}

QList<Reservation> ReservationRepository::getReservationsByTable(int tableId)
{
    QList<Reservation> reservations;
    QSqlQuery query(m_db);

    query.prepare(R"(
        SELECT * FROM reservations 
        WHERE table_id = ? 
        ORDER BY reservation_datetime ASC
    )");

    query.addBindValue(tableId);

    if (!query.exec()) {
        qWarning() << "Failed to get reservations by table:" << query.lastError().text();
        return reservations;
    }

    while (query.next()) {
        reservations.append(mapQueryToReservation(query));
    }

    return reservations;
}
