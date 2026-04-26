#ifndef SYSTEMTHEME_H
#define SYSTEMTHEME_H

#include <QObject>

class SystemTheme : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool darkMode READ darkMode NOTIFY darkModeChanged)

public:
    explicit SystemTheme(QObject *parent = nullptr);

    bool darkMode() const;

signals:
    void darkModeChanged();

private:
    bool m_darkMode;

    void detectTheme();
};

#endif // SYSTEMTHEME_H
