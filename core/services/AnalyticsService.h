#ifndef ANALYTICSERVICE_H
#define ANALYTICSERVICE_H

#include <QObject>
#include <QVariantList>
#include <QString>
#include <QVariantMap>
#include "../data/AnalyticsRepository.h"

class AnalyticsService : public QObject
{
    Q_OBJECT

public:
    explicit AnalyticsService(AnalyticsRepository &analyticsRepo);

    Q_INVOKABLE QVariantMap getSnapshot();

private:
    AnalyticsRepository &m_analyticsRepo;
};

#endif // ANALYTICSERVICE_H
