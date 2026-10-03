#ifndef RESERVATION_H
#define RESERVATION_H

#include <QString>
#include <QDateTime>
#include "../enums/ReservationStatus.h"

struct Reservation {
    int id = -1;
    QString customerName;
    QString customerPhone;
    int pax;
    int tableId = -1;
    QDateTime reservationDateTime;
    int durationMinutes;
    ReservationStatus status;
    QString notes;
};

#endif // RESERVATION_H
