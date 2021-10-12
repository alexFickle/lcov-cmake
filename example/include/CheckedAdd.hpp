#include <type_traits>
#include <optional>
#include <limits>

/// @brief Checked integer addition.
/// @returns lhs + rhs if it does not overflow.
/// @retval std::nullopt on overflow.
template <typename T>
constexpr std::optional<T> CheckedAdd(T lhs, T rhs) noexcept
{
    static_assert(std::is_integral_v<T>, "CheckedAdd supports only integral types");
    if constexpr (std::is_unsigned_v<T>)
    {
        if (std::numeric_limits<T>::max() - lhs < rhs)
        {
            return {};
        }
        return lhs + rhs;
    }
    else
    {
        static_assert(std::is_signed_v<T>);
        if (lhs > 0)
        {
            if (std::numeric_limits<T>::max() - lhs < rhs)
            {
                return {};
            }
            return lhs + rhs;
        }
        else
        {
            if (std::numeric_limits<T>::min() - lhs > rhs)
            {
                return {};
            }
            return lhs + rhs;
        }
    }
}
