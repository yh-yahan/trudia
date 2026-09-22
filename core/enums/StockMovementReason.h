#ifndef STOCKMOVEMENTREASON_H
#define STOCKMOVEMENTREASON_H

#include <QString>

#define STOCK_MOVEMENT_REASONS(X) \
    X(Receive, "receive") \
    X(Sale, "sale") \
    X(Waste, "waste") \
    X(Adjustment, "adjustment")

enum class StockMovementReason {

#define X(name, key) name,

    STOCK_MOVEMENT_REASONS(X)

#undef X

};

inline QString toString(StockMovementReason reason)
{
    switch (reason) {

#define X(name, key) case StockMovementReason::name: return QStringLiteral(key);

    STOCK_MOVEMENT_REASONS(X)

#undef X

    }

    return {};
}

inline bool fromString(const QString &value, StockMovementReason &reason)
{
#define X(name, key) \
    if (value == QStringLiteral(key)) { \
        reason = StockMovementReason::name; \
        return true; \
    }

    STOCK_MOVEMENT_REASONS(X)

#undef X

    return false;
}

#endif // STOCKMOVEMENTREASON_H
