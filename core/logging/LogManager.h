#ifndef LOGMANAGER_H
#define LOGMANAGER_H

#include <QFile>
#include <QMutex>
#include <QTextStream>

class LogManager
{
public:
    static void initialize();

private:
    static void messageHandler(QtMsgType type, const QMessageLogContext &context, const QString &message);
    static void openLogFile();
    static void cleanupOldLogs();

    static QFile s_logFile;
    static QTextStream s_stream;
    static QMutex s_mutex;
    static QString s_currentDate;

    static constexpr int LOG_RETENTION_DAYS = 30;
};

#endif // LOGMANAGER_H
