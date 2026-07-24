#include "ReservationService.h"

#include "../constants/ReservationStatus.h"
#include "../constants/TableStatus.h"
#include "../logging/LoggingCategories.h"

ReservationService::ReservationService(
    ReservationRepository &reservationRepo,
    TableService &tableService,
    QObject *parent)
    : QObject(parent),
      m_reservationRepo(reservationRepo),
      m_tableService(tableService) {}

QVariantMap ReservationService::getSeatedReservationByTable(int tableId)
{
    const QList<Reservation> reservations =
        m_reservationRepo.getReservationsByTable(tableId);

    for (const Reservation &reservation : reservations)
    {
        if (reservation.status == ReservationStatus::Seated)
        {
            return reservationToVariantMap(reservation);
        }
    }

    return {};
}

QVariantMap ReservationService::getActiveReservationByTable(int tableId)
{
    const QList<Reservation> reservations = m_reservationRepo.getReservationsByTable(tableId);

    for (const Reservation &reservation : reservations)
    {
        if (reservation.status ==
                ReservationStatus::Cancelled ||
            reservation.status ==
                ReservationStatus::Completed ||
            reservation.status ==
                ReservationStatus::NoShow)
        {
            continue;
        }

        return reservationToVariantMap(reservation);
    }

    return {};
}

bool ReservationService::createReservation(
    const QVariantMap &data)
{
    const Reservation reservation = variantMapToReservation(data);

    const QDateTime start = reservation.reservationDateTime;

    const QDateTime end = start.addSecs(reservation.durationMinutes * 60);

    if (hasConflict(
            reservation.tableId,
            start,
            end))
    {
        return false;
    }

    bool ok = m_reservationRepo.createReservation(reservation);

    if (ok)
    {
        m_tableService.setTableStatus(reservation.tableId, TableStatus::Reserved);
        emit reservationChanged(reservation.tableId);
    }

    return ok;
}

bool ReservationService::updateReservation(
    const QVariantMap &data)
{
    const Reservation reservation = variantMapToReservation(data);
    
    const QDateTime start = reservation.reservationDateTime;
    const QDateTime end = start.addSecs(reservation.durationMinutes * 60);

    if (hasConflict(
            reservation.tableId,
            start,
            end,
            reservation.id))
    {
        return false;
    }

    bool ok = m_reservationRepo.updateReservation(reservation);

    if (ok)
    {
        emit reservationChanged(reservation.tableId);
    }

    return ok;
}

bool ReservationService::deleteReservation(int reservationId)
{
    return m_reservationRepo.deleteReservation(reservationId);
}

bool ReservationService::cancelReservation(int reservationId)
{
    const Reservation reservation = m_reservationRepo.getReservationById(reservationId);

    if (reservation.id <= 0)
    {
        qCWarning(logReservation) << "Cancel failed: reservation not found";
        return false;
    }

    bool ok = m_reservationRepo.updateReservationStatus(
        reservationId,
        ReservationStatus::Cancelled);

    if (ok)
    {
        m_tableService.setTableStatus(reservation.tableId, TableStatus::Available);
        emit reservationChanged(reservation.tableId);
    }

    return ok;
}

QVariantList ReservationService::getReservationsByDate(
    const QDate &date)
{
    QVariantList list;

    const QList<Reservation> reservations =
        m_reservationRepo.getReservationsByDate(
            date);

    for (const Reservation &reservation : reservations)
    {
        list.append(
            reservationToVariantMap(
                reservation));
    }

    return list;
}

bool ReservationService::isTableAvailable(
    int tableId,
    const QDateTime &start,
    int durationMinutes)
{
    const QDateTime end = start.addSecs(durationMinutes * 60);

    return !hasConflict(
        tableId,
        start,
        end);
}

bool ReservationService::hasConflict(
    int tableId,
    const QDateTime &start,
    const QDateTime &end,
    int excludeReservationId)
{
    const QList<Reservation> reservations = m_reservationRepo.getReservationsByTable(tableId);

    for (const Reservation &reservation : reservations)
    {
        if (reservation.id == excludeReservationId)
        {
            continue;
        }

        if (reservation.status == ReservationStatus::Cancelled ||
            reservation.status == ReservationStatus::Completed)
        {
            continue;
        }

        const QDateTime existingStart = reservation.reservationDateTime;
        const QDateTime existingEnd = existingStart.addSecs(reservation.durationMinutes * 60);
        const bool overlaps = start < existingEnd && end > existingStart;

        if (overlaps)
        {
            return true;
        }
    }

    return false;
}

QVariantMap ReservationService::reservationToVariantMap(const Reservation &reservation)
{
    QVariantMap map;

    map["id"] = reservation.id;
    map["customerName"] = reservation.customerName;
    map["customerPhone"] = reservation.customerPhone;
    map["pax"] = reservation.pax;
    map["tableId"] = reservation.tableId;
    map["reservationDateTime"] = reservation.reservationDateTime;
    map["durationMinutes"] = reservation.durationMinutes;
    map["status"] = reservation.status;
    map["notes"] = reservation.notes;

    return map;
}

Reservation ReservationService::variantMapToReservation(const QVariantMap &data)
{
    Reservation reservation;

    reservation.id = data.value("id").toInt();
    reservation.customerName = data.value("customerName").toString();
    reservation.customerPhone = data.value("customerPhone").toString();
    reservation.pax = data.value("pax").toInt();
    reservation.tableId = data.value("tableId").toInt();
    reservation.reservationDateTime = data.value("reservationDateTime").toDateTime();
    reservation.durationMinutes = data.value("durationMinutes").toInt();
    reservation.status = data.value("status").toString();
    reservation.notes = data.value("notes").toString();

    return reservation;
}
