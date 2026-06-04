// -------------------------------------------------------------------------------------------------
// SPDX-License-Identifier: Apache-2.0
// -------------------------------------------------------------------------------------------------

#ifndef KPROF_PARAM_CONCEPTS_HPP
#define KPROF_PARAM_CONCEPTS_HPP

#include <ranges>

namespace kprof::param {
template <typename T>
concept space = std::ranges::input_range<T>;

template <typename T>
concept sized_space = space<T> && std::ranges::sized_range<T>;

template <typename T>
concept indexed_space = sized_space<T> && std::ranges::random_access_range<T>;

template <typename T>
concept source = requires(T src) {
  typename T::value_type;
  { src.next() } -> std::same_as<std::optional<typename T::value_type>>;
};

} // namespace kprof::param

#endif // KPROF_PARAM_CONCEPTS_HPP
