#ifndef MOCKMEMBERSHIPSETTINGSREPOSITORY_H
#define MOCKMEMBERSHIPSETTINGSREPOSITORY_H

#include "../../core/data/MembershipSettingsRepository.h"
#include "../../core/domain/MembershipSettings.h"

class MockMembershipSettingsRepository : public MembershipSettingsRepository
{
public:
    MockMembershipSettingsRepository();

    // overridden methods from base class
    std::optional<MembershipSettings> get();

    // test helper methods
    void setFakeSettings(const MembershipSettings &settings);
    void setGetResult(bool result);

    // call recording
    int getCallCount() const;

private:
    std::optional<MembershipSettings> m_fakeSettings;
    bool m_getResult = true;

    int m_getCallCount = 0;
};

#endif // MOCKMEMBERSHIPSETTINGSREPOSITORY_H
