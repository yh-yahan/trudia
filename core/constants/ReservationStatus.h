#ifndef RESERVATIONSTATUS_H
#define RESERVATIONSTATUS_H

#include <QString>

namespace ReservationStatus
{
    inline const QString Booked = "booked";
    inline const QString Seated = "seated";
    inline const QString Completed = "completed";
    inline const QString Cancelled = "cancelled";
    inline const QString NoShow = "no_show";
}

#endif // RESERVATIONSTATUS_H
