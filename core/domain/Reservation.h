#ifndef RESERVATION_H
#define RESERVATION_H

#include <QString>
#include <QDateTime>

class Reservation
{
public:
    int id = -1;
    QString customerName;
    QString customerPhone;
    int pax;
    int tableId = -1;
    QDateTime reservationDateTime;
    int durationMinutes;
    QString status;
    QString notes;
};

#endif // RESERVATION_H
