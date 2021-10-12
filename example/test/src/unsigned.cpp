#include "AddTester.hpp"

#include <gtest/gtest.h>

#include <cstdint>

using std::uint8_t;

TEST(u8, normal)
{
    EXPECT_SUM_IS(uint8_t(0), uint8_t(1), uint8_t(1));
    EXPECT_SUM_IS(uint8_t(1), uint8_t(1), uint8_t(2));
    EXPECT_SUM_IS(uint8_t(1), uint8_t(2), uint8_t(3));
}

TEST(u8, nearOverflow)
{
    EXPECT_SUM_IS(uint8_t(0), uint8_t(255), uint8_t(255));
    EXPECT_SUM_IS(uint8_t(1), uint8_t(254), uint8_t(255));
    EXPECT_SUM_IS(uint8_t(127), uint8_t(128), uint8_t(255));
}

TEST(u8, overflow)
{
    EXPECT_SUM_OVERFLOWS(uint8_t(1), uint8_t(255));
    EXPECT_SUM_OVERFLOWS(uint8_t(2), uint8_t(254));
    EXPECT_SUM_OVERFLOWS(uint8_t(128), uint8_t(128));
}
