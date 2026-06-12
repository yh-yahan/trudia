#ifndef RESERVATIONSERVICE_H
#define RESERVATIONSERVICE_H

#include <QObject>
#include <QVariantMap>
#include <QVariantList>
#include <QDate>
#include <QDateTime>
#include "../data/ReservationRepository.h"
#include "../domain/Reservation.h"
#include "./TableService.h"

class ReservationService : public QObject
{
    Q_OBJECT

public:
    explicit ReservationService(ReservationRepository &reservationRepo,
        TableService &tableService,
        QObject *parent = nullptr);

    Q_INVOKABLE QVariantMap getActiveReservationByTable(int tableId);
    Q_INVOKABLE bool createReservation(const QVariantMap &data);
    Q_INVOKABLE bool updateReservation(const QVariantMap &data);
    Q_INVOKABLE bool deleteReservation(int reservationId);
    Q_INVOKABLE bool cancelReservation(int reservationId);
    Q_INVOKABLE QVariantList getReservationsByDate(const QDate &date);
    Q_INVOKABLE bool isTableAvailable(int tableId,
        const QDateTime &start,
        int durationMinutes);

signals:
    void reservationChanged(int tableId);

private:
    bool hasConflict(
        int tableId,
        const QDateTime &start,
        const QDateTime &end,
        int excludeReservationId = -1);
    QVariantMap reservationToVariantMap(const Reservation &reservation);
    Reservation variantMapToReservation(const QVariantMap &data);

    ReservationRepository &m_reservationRepo;
    TableService &m_tableService;
};

#endif // RESERVATIONSERVICE_H
