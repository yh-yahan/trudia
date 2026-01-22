#ifndef USER_H
#define USER_H

#include <QString>

class User
{
public:
    int id = -1;
    QString username;
    QString password;
    QString role;
};

#endif // USER_H
