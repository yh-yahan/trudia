#ifndef RESTAURANT_H
#define RESTAURANT_H

#include <QString>

class Restaurant
{
public:
    int id = -1;
    QString name;
    QString address;
    std::optional<QString> phone_number;
    std::optional<QString> email;
    std::optional<QString> website;
};

#endif // RESTAURANT_H
