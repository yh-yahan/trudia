#ifndef RESERVATIONSTATUS_H
#define RESERVATIONSTATUS_H

#include <QString>

#define RESERVATION_STATUS(X) \
    X(Booked, "booked") \
    X(Seated, "seated") \
    X(Completed, "completed") \
    X(Cancelled, "cancelled") \
    X(NoShow, "no_show")

enum class ReservationStatus {

#define X(name, key) name,

    RESERVATION_STATUS(X)

#undef X

};

inline QString toString(ReservationStatus reason)
{
    switch (reason) {

#define X(name, key) case ReservationStatus::name: return QStringLiteral(key);

    RESERVATION_STATUS(X)

#undef X

    }

    return {};
}

inline bool fromString(const QString &value, ReservationStatus &reason)
{
#define X(name, key) \
    if (value == QStringLiteral(key)) { \
        reason = ReservationStatus::name; \
        return true; \
    }

    RESERVATION_STATUS(X)

#undef X

    return false;
}

#endif // RESERVATIONSTATUS_H
