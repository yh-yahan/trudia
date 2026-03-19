#include "PrintLayoutHelper.h"

int PrintLayoutHelper::lineWidth(const QString &paperWidth)
{
    if (paperWidth == "58mm")
        return 32;

    return 48; // 80mm
}
