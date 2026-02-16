#include "EscPosBuilder.h"

EscPosBuilder::EscPosBuilder() {}

void EscPosBuilder::initialize()
{
    m_buffer.append("\x1B\x40");
}

void EscPosBuilder::setBold(bool enabled)
{
    m_buffer.append("\x1B\x45");
    m_buffer.append(enabled ? "\x01" : "\x00");
}

void EscPosBuilder::setAlignLeft()
{
    m_buffer.append("\x1B\x61\x00");
}

void EscPosBuilder::setAlignCenter()
{
    m_buffer.append("\x1B\x61\x01");
}

void EscPosBuilder::setAlignRight()
{
    m_buffer.append("\x1B\x61\x02");
}

void EscPosBuilder::addText(const QString &text)
{
    m_buffer.append(text.toUtf8());
}

void EscPosBuilder::newLine()
{
    m_buffer.append("\n");
}

void EscPosBuilder::cut(const QString &cut_mode)
{
    if (cut_mode == "Full Cut"){
        m_buffer.append("\x1B\x64\x03");
        m_buffer.append("\x1D\x56\x00");
    } else if (cut_mode == "Partial Cut"){
        m_buffer.append("\x1B\x64\x03");
        m_buffer.append("\x1D\x56\x01");
    } else {
        return;
    };
}

QByteArray EscPosBuilder::data() const
{
    return m_buffer;
}

void EscPosBuilder::clear()
{
    m_buffer.clear();
}
