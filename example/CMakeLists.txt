cmake_minimum_required(VERSION 3.19)

project(my_project CXX)

include(${CMAKE_CURRENT_BINARY_DIR}/conanbuildinfo.cmake)
conan_basic_setup()

# conditionally enable coverage
option(LCOV_ENABLED "enables code coverage with lcov" OFF)
if(LCOV_ENABLED)
    include(lcov)
    # including every local file except ones from the test directory
    lcov_enable(INCLUDE ** EXCLUDE test/**)
endif()

include(CTest)

add_library(checked_add INTERFACE)
target_include_directories(checked_add INTERFACE include)
target_compile_features(checked_add INTERFACE cxx_std_17)

if(BUILD_TESTING)
    add_subdirectory(test)
endif()
