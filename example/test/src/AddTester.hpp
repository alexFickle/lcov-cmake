#include "CheckedAdd.hpp"

#include <gtest/gtest.h>

/// Helper that asserts that (lhs + rhs) == (rhs + lhs) == result.
template <typename T>
testing::AssertionResult SumIs(T lhs, T rhs, T result)
{
    // lhs + rhs
    auto sum = CheckedAdd(lhs, rhs);
    if (!sum.has_value())
    {
        return testing::AssertionFailure() << +lhs << " + " << +rhs << " unexpectedly overflowed";
    }
    if (sum.value() != result)
    {
        return testing::AssertionFailure() << +lhs << " + " << +rhs << " resulted in " << +sum.value() << " instead of the expected " << +result;
    }

    // rhs + lhs
    sum = CheckedAdd(rhs, lhs);
    if (!sum.has_value())
    {
        return testing::AssertionFailure() << +rhs << " + " << +lhs << " unexpectedly overflowed";
    }
    if (sum.value() != result)
    {
        return testing::AssertionFailure() << +rhs << " + " << +lhs << " resulted in " << +sum.value() << " instead of the expected " << +result;
    }

    return testing::AssertionSuccess();
}

/// Wrapper for SumIs().
#define EXPECT_SUM_IS(lhs, rhs, result) EXPECT_TRUE(SumIs(lhs, rhs, result))

/// Helper function that asserts that both (lhs + rhs) and (rhs + lhs) both overflow.
template <typename T>
testing::AssertionResult SumOverflows(T lhs, T rhs)
{
    // lhs + rhs
    auto sum = CheckedAdd(lhs, rhs);
    if (sum.has_value())
    {
        return testing::AssertionFailure() << +lhs << " + " << +rhs << " resulted in " << +sum.value() << " instead of the expected overflow.";
    }

    // rhs + lhs
    sum = CheckedAdd(rhs, lhs);
    if (sum.has_value())
    {
        return testing::AssertionFailure() << +rhs << " + " << +lhs << " resulted in " << +sum.value() << " instead of the expected overflow.";
    }

    return testing::AssertionSuccess();
}

/// Wrapper for SumOverflows().
#define EXPECT_SUM_OVERFLOWS(lhs, rhs) EXPECT_TRUE(SumOverflows(lhs, rhs))
