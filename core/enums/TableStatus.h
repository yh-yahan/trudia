#ifndef TABLESTATUS_H
#define TABLESTATUS_H

#include <QString>

#define TABLE_STATUS(X) \
    X(Available, "available") \
    X(Occupied, "occupied") \
    X(Reserved, "reserved")

enum class TableStatus {

#define X(name, key) name,

    TABLE_STATUS(X)

#undef X

};

inline QString toString(TableStatus reason)
{
    switch (reason) {

#define X(name, key) case TableStatus::name: return QStringLiteral(key);

    TABLE_STATUS(X)

#undef X

    }

    return {};
}

inline bool fromString(const QString &value, TableStatus &reason)
{
#define X(name, key) \
    if (value == QStringLiteral(key)) { \
        reason = TableStatus::name; \
        return true; \
    }

    TABLE_STATUS(X)

#undef X

    return false;
}

#endif // TABLESTATUS_H
