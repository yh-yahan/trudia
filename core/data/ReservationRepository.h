#ifndef RESERVATIONREPOSITORY_H
#define RESERVATIONREPOSITORY_H

#include <QSqlDatabase>
#include "../domain/Reservation.h"

class ReservationRepository
{
public:
    explicit ReservationRepository(QSqlDatabase db);
    bool createReservation(const Reservation &reservation);
    bool updateReservation(const Reservation &reservation);
    bool deleteReservation(int reservationId);
    bool updateReservationStatus(int reservationId, const ReservationStatus &status);
    Reservation getReservationById(int reservationId);
    QList<Reservation> getReservations();
    QList<Reservation> getReservationsByDate(const QDate &date);
    QList<Reservation> getReservationsByTable(int tableId);

private:
    QSqlDatabase m_db;

    Reservation mapQueryToReservation(const QSqlQuery &query);
};

#endif // RESERVATIONREPOSITORY_H
