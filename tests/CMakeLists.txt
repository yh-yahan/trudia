add_executable(tst_MembershipService
    tst_MembershipService.cpp

    mocks/MockMembershipRepository.cpp
    mocks/MockMembershipSettingsRepository.cpp
    mocks/MockMembershipTransactionRepository.cpp
)

target_include_directories(tst_MembershipService PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/mocks
)

target_link_libraries(tst_MembershipService
    PRIVATE
        trudia_core
        Qt6::Test
        Qt6::Sql
)

add_test(
    NAME tst_MembershipService
    COMMAND tst_MembershipService
)
