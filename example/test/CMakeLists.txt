cmake_minimum_required(VERSION 3.19)

include(GoogleTest)

add_executable(test_checked_add
    src/signed.cpp
    src/unsigned.cpp
)
target_link_libraries(test_checked_add PRIVATE checked_add ${CONAN_LIBS})

gtest_discover_tests(test_checked_add)