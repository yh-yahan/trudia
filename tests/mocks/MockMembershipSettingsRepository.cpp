#include "MockMembershipSettingsRepository.h"

MockMembershipSettingsRepository::MockMembershipSettingsRepository()
    : MembershipSettingsRepository(QSqlDatabase()){}

std::optional<MembershipSettings> MockMembershipSettingsRepository::get()
{
    m_getCallCount++;

    if (!m_getResult)
    {
        return std::nullopt;
    }

    return m_fakeSettings;
}

// test helper methods

void MockMembershipSettingsRepository::setFakeSettings(
    const MembershipSettings &settings)
{
    m_fakeSettings = settings;
}

void MockMembershipSettingsRepository::setGetResult(bool result)
{
    m_getResult = result;
}

// call recording

int MockMembershipSettingsRepository::getCallCount() const
{
    return m_getCallCount;
}
