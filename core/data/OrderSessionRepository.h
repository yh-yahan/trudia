#ifndef ORDERSESSIONREPOSITORY_H
#define ORDERSESSIONREPOSITORY_H

#include <QString>
#include <QSqlDatabase>
#include "../domain/OrderSession.h"

class OrderSessionRepository
{
public:
    explicit OrderSessionRepository(QSqlDatabase db);

    std::vector<OrderSession> getAllActiveOrderSessions();
    std::optional<OrderSession> getById(const int &orderSessionId);
    std::optional<OrderSession> getByOrderId(int orderId);
    int getMaxDisplayNumberForDate(const QString &date);
    int findOpenSessionByTableId(int const &tableId);
    int create(const OrderSession &orderSession);
    void update(const OrderSession &orderSession);
    void markAsPaid(int orderId);

private:
    QSqlDatabase m_db;
};

#endif // ORDERSESSIONREPOSITORY_H
