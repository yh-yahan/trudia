#include "LogManager.h"

#include <QFileInfo>
#include <QDate>
#include <QDateTime>
#include <QDir>
#include <QMutexLocker>
#include <QStandardPaths>

QFile LogManager::s_logFile;
QTextStream LogManager::s_stream;
QMutex LogManager::s_mutex;
QString LogManager::s_currentDate;

void LogManager::initialize()
{
    openLogFile();

    qInstallMessageHandler(messageHandler);

    cleanupOldLogs();

    qInfo() << "Logging initialized.";
}

void LogManager::cleanupOldLogs()
{
    const QString appData = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    const QString logDirPath = appData + "/logs";

    QDir logDir(logDirPath);

    if (!logDir.exists()) return;

    const QDate cutoffDate = QDate::currentDate().addDays(-LOG_RETENTION_DAYS);
    const QFileInfoList files = logDir.entryInfoList({"*.log"}, QDir::Files);

    for (const QFileInfo &file : files)
    {
        const QString filename = file.completeBaseName();
        const QDate fileDate = QDate::fromString(filename, "yyyy-MM-dd");

        if (!fileDate.isValid()) continue;

        if (fileDate < cutoffDate) QFile::remove(file.absoluteFilePath());
    }
}

void LogManager::openLogFile()
{
    const QString appData = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);

    const QString logDir = appData + "/logs";

    QDir().mkpath(logDir);

    s_currentDate = QDate::currentDate().toString("yyyy-MM-dd");

    const QString filename = QString("%1/%2.log").arg(logDir, s_currentDate);

    if (s_logFile.isOpen()) s_logFile.close();

    s_logFile.setFileName(filename);

    if (s_logFile.open(QIODevice::Append | QIODevice::Text)) s_stream.setDevice(&s_logFile);
}

void LogManager::messageHandler(QtMsgType type, const QMessageLogContext &context, const QString &message)
{
    QMutexLocker locker(&s_mutex);

    const QString today = QDate::currentDate().toString("yyyy-MM-dd");

    if (today != s_currentDate) openLogFile();

    QString level;

    switch (type)
    {
    case QtDebugMsg:
        level = "DEBUG";
        break;

    case QtInfoMsg:
        level = "INFO";
        break;

    case QtWarningMsg:
        level = "WARN";
        break;

    case QtCriticalMsg:
        level = "ERROR";
        break;

    case QtFatalMsg:
        level = "FATAL";
        break;
    }

    const QString timestamp = QDateTime::currentDateTime().toString("yyyy-MM-dd HH:mm:ss");

    QString line = QString("%1 [%2] [%3] %4").arg(timestamp, level, context.category, message);

    s_stream << line << Qt::endl;
    s_stream.flush();

#ifndef QT_NO_DEBUG_OUTPUT
    fprintf(stderr, "%s\n", line.toUtf8().constData());
#endif

    if (type == QtFatalMsg)
        abort();
}
