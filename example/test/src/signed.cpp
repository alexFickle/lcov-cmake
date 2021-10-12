#include "AddTester.hpp"

#include <gtest/gtest.h>

#include <cstdint>

using std::int8_t;

TEST(i8, normal)
{
    EXPECT_SUM_IS(int8_t(1), int8_t(2), int8_t(3));
    EXPECT_SUM_IS(int8_t(-1), int8_t(-2), int8_t(-3));
    EXPECT_SUM_IS(int8_t(-1), int8_t(2), int8_t(1));
    EXPECT_SUM_IS(int8_t(1), int8_t(-2), int8_t(-1));
}

TEST(i8, nearPositiveOverflow)
{
    EXPECT_SUM_IS(int8_t(0), int8_t(127), int8_t(127));
    EXPECT_SUM_IS(int8_t(1), int8_t(126), int8_t(127));
    EXPECT_SUM_IS(int8_t(63), int8_t(64), int8_t(127));
}

TEST(i8, nearNegativeOverflow)
{
    EXPECT_SUM_IS(int8_t(0), int8_t(-128), int8_t(-128));
    EXPECT_SUM_IS(int8_t(-1), int8_t(-127), int8_t(-128));
    EXPECT_SUM_IS(int8_t(-64), int8_t(-64), int8_t(-128));
}

TEST(i8, positiveOverflow)
{
    EXPECT_SUM_OVERFLOWS(int8_t(1), int8_t(127));
    EXPECT_SUM_OVERFLOWS(int8_t(2), int8_t(126));
    EXPECT_SUM_OVERFLOWS(int8_t(64), int8_t(64));
}

TEST(i8, negativeOverflow)
{
    EXPECT_SUM_OVERFLOWS(int8_t(-1), int8_t(-128));
    EXPECT_SUM_OVERFLOWS(int8_t(-2), int8_t(-127));
    EXPECT_SUM_OVERFLOWS(int8_t(-64), int8_t(-65));
}
