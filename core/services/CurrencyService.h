#ifndef CURRENCYSERVICE_H
#define CURRENCYSERVICE_H

#include <QString>
#include <QHash>

class CurrencyService
{
public:
    struct CurrencyInfo {
        QString code;
        QString symbol;
        QString name;
        int precision;
        QString position; // prefix/suffix
    };

    static CurrencyInfo get(const QString &code);
    static QList<CurrencyInfo> all();

    QString getSymbol(const QString &code) {
        return get(code).symbol;
    }

private:
    static const QHash<QString, CurrencyInfo>& currencyMap();
};

#endif // CURRENCYSERVICE_H
