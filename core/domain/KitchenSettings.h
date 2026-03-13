#ifndef KITCHENSETTINGS_H
#define KITCHENSETTINGS_H

#include <QString>

class KitchenSettings {
public:
    int id = -1;
    QString mode;
    QString ticket_print_timing;
    bool require_ready_for_checkout; // active/revoked
};

#endif // KITCHENSETTINGS_H
