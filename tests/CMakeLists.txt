# === Unit Tests ===
add_executable(tst_MembershipService
    unit/tst_MembershipService.cpp
    unit/mocks/MockMembershipRepository.cpp
    unit/mocks/MockMembershipSettingsRepository.cpp
    unit/mocks/MockMembershipTransactionRepository.cpp
)

target_include_directories(tst_MembershipService PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/unit
    ${CMAKE_CURRENT_SOURCE_DIR}/unit/mocks
)

target_link_libraries(tst_MembershipService PRIVATE
    trudia_core
    Qt6::Test
    Qt6::Sql
)

add_test(NAME tst_MembershipService COMMAND tst_MembershipService)


# === Integration Tests ===
add_executable(tst_CheckoutService
    integration/tst_CheckoutService.cpp
    integration/CheckoutServiceTestHelper.cpp
)

set_source_files_properties(${CMAKE_SOURCE_DIR}/resources.qrc
    PROPERTIES QT_RESOURCE_ALIAS resources.qrc
)

qt_add_resources(tst_CheckoutService
    FILES ${CMAKE_SOURCE_DIR}/resources.qrc
)

target_include_directories(tst_CheckoutService PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/integration
)

target_link_libraries(tst_CheckoutService
    PRIVATE
        trudia_core
        Qt6::Test
        Qt6::Sql
)

add_test(NAME tst_CheckoutService COMMAND tst_CheckoutService)
