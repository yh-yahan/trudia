#include "PasswordHasher.h"

#include <QCryptographicHash>

QString PasswordHasher::hash(const QString &password)
{
    return QString(QCryptographicHash::hash(password.toUtf8(),QCryptographicHash::Sha256).toHex());
}

bool PasswordHasher::verify(const QString &password, const QString &hash)
{
    return PasswordHasher::hash(password) == hash;
}
