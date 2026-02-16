#ifndef ESCPOSBUILDER_H
#define ESCPOSBUILDER_H

#include <QByteArray>
#include <QString>

class EscPosBuilder
{
public:
    EscPosBuilder();

    void initialize();

    void setBold(bool enabled);
    void setAlignLeft();
    void setAlignCenter();
    void setAlignRight();

    void addText(const QString &text);
    void newLine();

    void cut(const QString &cut_mode);

    QByteArray data() const;
    void clear();

private:
    QByteArray m_buffer;
};

#endif // ESCPOSBUILDER_H
