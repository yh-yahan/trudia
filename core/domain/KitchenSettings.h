#ifndef KITCHENSETTINGS_H
#define KITCHENSETTINGS_H

#include <QString>

struct KitchenSettings {
    int id = -1;
    QString mode;
    QString ticket_print_timing;
    bool require_ready_for_checkout;
    bool allow_edit_after_send;
};

#endif // KITCHENSETTINGS_H
