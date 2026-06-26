#include "EscPosBuilder.h"

EscPosBuilder::EscPosBuilder() {}

void EscPosBuilder::command(std::initializer_list<char> bytes)
{
    for (char b : bytes)
        m_buffer.append(b);
}

void EscPosBuilder::initialize()
{
    command({0x1B, 0x40});
}

void EscPosBuilder::setBold(bool enabled)
{
    command({0x1B, 0x45, enabled ? 0x01 : 0x00});
}

void EscPosBuilder::setAlignLeft()
{
    command({0x1B, 0x61, 0x00});
}

void EscPosBuilder::setAlignCenter()
{
    command({0x1B, 0x61, 0x01});
}

void EscPosBuilder::setAlignRight()
{
    command({0x1B, 0x61, 0x02});
}

void EscPosBuilder::addText(const QString &text)
{
    m_buffer.append(text.toLocal8Bit());
}

void EscPosBuilder::newLine()
{
    command({'\n'});
}

void EscPosBuilder::cut(const QString &cut_mode)
{
    if (cut_mode == "full"){
        command({0x1B, 0x64, 0x03});
        command({0x1D, 0x56, 0x00});
    } else if (cut_mode == "partial"){
        command({0x1B, 0x64, 0x03});
        command({0x1D, 0x56, 0x01});
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
