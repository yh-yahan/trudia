#ifndef OPENORDERVIEW_H
#define OPENORDERVIEW_H

#include <QString>
#include <optional>

struct OpenOrderView {
    int id;
    int display_number;
    int order_session_id;
    QString status;
    QString notes;

    QString order_type;
    std::optional<int> table_id;
};

#endif // OPENORDERVIEW_H
