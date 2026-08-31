#ifndef USER_H
#define USER_H

#include <QString>

struct User {
    int id = -1;
    QString username;
    QString password;
    QString role; // admin/service_staff/kitchen_staff
    QString deactivated_at;
    QString deleted_at;
};

#endif // USER_H
