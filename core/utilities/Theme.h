#ifndef THEME_H
#define THEME_H

#include <QObject>
#include <QColor>
#include "SystemTheme.h"

class Theme : public QObject {
    Q_OBJECT

    Q_PROPERTY(QColor background READ background NOTIFY themeChanged)
    Q_PROPERTY(QColor surface READ surface NOTIFY themeChanged)
    Q_PROPERTY(QColor border READ border NOTIFY themeChanged)
    Q_PROPERTY(QColor text READ text NOTIFY themeChanged)
    Q_PROPERTY(QColor secondaryText READ secondaryText NOTIFY themeChanged)
    Q_PROPERTY(QColor orange READ orange NOTIFY themeChanged)
    Q_PROPERTY(QColor green READ green NOTIFY themeChanged)

public:
    explicit Theme(SystemTheme *systemTheme, QObject *parent = nullptr)
        : QObject(parent),
          m_systemTheme(systemTheme)
    {
        connect(m_systemTheme, &SystemTheme::darkModeChanged,
                this, &Theme::onSystemThemeChanged);
    }

    Q_INVOKABLE QColor background() const {
        return m_systemTheme->darkMode()
            ? QColor("#121212")
            : QColor("#FFFFFF");
    }

    Q_INVOKABLE QColor surface() const {
        return m_systemTheme->darkMode()
            ? QColor("#1E1E1E")
            : QColor("#F5F5F5");
    }

    Q_INVOKABLE QColor border() const {
        return m_systemTheme->darkMode()
            ? QColor("#2A2A2A")
            : QColor("#DDDDDD");
    }

    Q_INVOKABLE QColor text() const {
        return m_systemTheme->darkMode()
            ? QColor("#FFFFFF")
            : QColor("#000000");
    }

    Q_INVOKABLE QColor secondaryText() const {
        return m_systemTheme->darkMode()
            ? QColor("#AAAAAA")
            : QColor("#555555");
    }

    Q_INVOKABLE QColor orange() const {
        return m_systemTheme->darkMode()
            ? QColor("#FFB74D")
            : QColor("#F57C00");
    }

    Q_INVOKABLE QColor green() const {
        return m_systemTheme->darkMode()
            ? QColor("#66BB6A")
            : QColor("#2E7D32");
    }

    Q_INVOKABLE QColor primary() const {
        return QColor("#9a7bff");
    }

    Q_INVOKABLE QColor error() const {
        return QColor("#ff0000");
    }

signals:
    void themeChanged();

private slots:
    void onSystemThemeChanged() {
        emit themeChanged();
    }

private:
    SystemTheme *m_systemTheme;
};

#endif // THEME_H
