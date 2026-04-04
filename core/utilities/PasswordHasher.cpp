#include "PasswordHasher.h"

#include <QCryptographicHash>
#include <sodium.h>

QString PasswordHasher::hash(const QString &password)
{
    if (sodium_init() < 0) {
        return {};
    }

    char hashed[crypto_pwhash_STRBYTES];
    crypto_pwhash_str(
        hashed,
        password.toUtf8().constData(),
        password.toUtf8().size(),
        crypto_pwhash_OPSLIMIT_INTERACTIVE,
        crypto_pwhash_MEMLIMIT_INTERACTIVE
    );

    return QString::fromUtf8(hashed);
}

bool PasswordHasher::verify(const QString &password, const QString &hash)
{
    if (sodium_init() < 0) return false;

    return crypto_pwhash_str_verify(
        hash.toUtf8().constData(),
        password.toUtf8().constData(),
        password.toUtf8().size()
    ) == 0;
}
