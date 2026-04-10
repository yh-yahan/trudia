#include "SystemTheme.h"

#ifdef Q_OS_WIN
#include <QSettings>
#endif

SystemTheme::SystemTheme(QObject *parent)
    : QObject(parent),
    m_darkMode(false)
{
    detectTheme();
}

bool SystemTheme::darkMode() const
{
    return m_darkMode;
}

void SystemTheme::detectTheme()
{
#ifdef Q_OS_WIN
    QSettings settings(
        "HKEY_CURRENT_USER\\Software\\Microsoft\\Windows\\CurrentVersion\\Themes\\Personalize",
        QSettings::NativeFormat);

    int value = settings.value("AppsUseLightTheme", 1).toInt();
    bool newValue = (value == 0);

#else
    bool newValue = false;
#endif

    if (m_darkMode == newValue)
        return;

    m_darkMode = newValue;
    emit darkModeChanged();
}
