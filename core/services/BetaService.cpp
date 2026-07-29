#include "BetaService.h"

#include <QNetworkRequest>
#include <QUrlQuery>
#include <QJsonDocument>
#include <QJsonObject>
#include "../logging/LoggingCategories.h"

BetaService::BetaService(QObject *parent) : QObject(parent) {}

void BetaService::submitBetaInfo(const QString &name, const QString &email)
{
    const QString formspreeUrl = "https://formspree.io/f/mlgqzqwg";

    if (email.trimmed().isEmpty()) {
        qCInfo(logApplication) << "BetaService: empty email, skipping submit";
        emit submitFinished(false);
        return;
    }

    QUrl url(formspreeUrl);
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/x-www-form-urlencoded");

    request.setRawHeader("Accept", "application/json");
    request.setRawHeader("User-Agent", "Trudia-Beta/0.2.1");

    QUrlQuery params;
    params.addQueryItem("name", name.trimmed());
    params.addQueryItem("email", email.trimmed());
    params.addQueryItem("_subject", "Trudia Beta Signup");
    params.addQueryItem("version", "0.2.1");

    QNetworkReply *reply = m_manager.post(
        request,
        params.query(QUrl::FullyEncoded).toUtf8()
    );

    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        const bool success = (reply->error() == QNetworkReply::NoError);

        if (success) {
            qCInfo(logApplication) << "BetaService: Formspree submit succeeded";
        } else {
            qCWarning(logApplication) << "BetaService: Formspree submit failed:"
                                      << reply->errorString();
        }

        reply->deleteLater();
        emit submitFinished(success);
    });
}
