// -------------------------------------------------------------------------------------------------
// SPDX-License-Identifier: Apache-2.0
// -------------------------------------------------------------------------------------------------

#ifndef KPROF_PARAM_STORED_LINSPACE_HPP
#define KPROF_PARAM_STORED_LINSPACE_HPP

#include <atomic>
#include <concepts>
#include <cstddef>
#include <kprof/exception.hpp>
#include <kprof/param/concepts.hpp>
#include <optional>
#include <vector>

namespace kprof::param {

template <std::integral T>
class stored_linspace {
public:
  using value_type = T;
  using container_type = std::vector<T>;
  using const_iterator = typename container_type::const_iterator;

  stored_linspace(T first, T last, std::size_t count);

  [[nodiscard]] const_iterator begin() const noexcept;
  [[nodiscard]] const_iterator end() const noexcept;

  [[nodiscard]] std::size_t size() const noexcept;
  [[nodiscard]] bool empty() const noexcept;

  std::optional<value_type> next() noexcept;

  void reset() noexcept;

private:
  static container_type make_values(T first, T last, std::size_t count);

  container_type values_;
  std::atomic<std::size_t> index_{0};
};

template <std::integral T>
stored_linspace<T>::stored_linspace(T first, T last, std::size_t count)
: values_(make_values(first, last, count))
{
}

template <std::integral T>
typename stored_linspace<T>::const_iterator stored_linspace<T>::begin() const noexcept
{
  return values_.begin();
}

template <std::integral T>
typename stored_linspace<T>::const_iterator stored_linspace<T>::end() const noexcept
{
  return values_.end();
}

template <std::integral T>
std::size_t stored_linspace<T>::size() const noexcept
{
  return values_.size();
}

template <std::integral T>
bool stored_linspace<T>::empty() const noexcept
{
  return values_.empty();
}

template <std::integral T>
std::optional<typename stored_linspace<T>::value_type> stored_linspace<T>::next() noexcept
{
  const auto i = index_.fetch_add(1, std::memory_order_relaxed);

  if (i >= values_.size()) {
    return std::nullopt;
  }

  return values_[i];
}

template <std::integral T>
void stored_linspace<T>::reset() noexcept
{
  index_.store(0, std::memory_order_relaxed);
}

template <std::integral T>
typename stored_linspace<T>::container_type stored_linspace<T>::make_values(
  T first, T last, std::size_t count)
{
  container_type values;
  values.reserve(count);

  if (count == 0) {
    return values;
  }

  if (count == 1) {
    values.push_back(first);
    return values;
  }

  if (count > 1) {
    const auto intervals = static_cast<T>(count - 1);
    const auto distance = last - first;

    if (distance % intervals != 0) {
      throw kprof::exception::invalid_argument{
        "integral stored_linspace requires (last - first) divisible by (count - 1)"};
    }
  }

  for (std::size_t i = 0; i < count; ++i) {
    const auto numerator = static_cast<long double>(i);
    const auto denominator = static_cast<long double>(count - 1);

    const auto value = static_cast<long double>(first)
                       + (static_cast<long double>(last) - static_cast<long double>(first))
                           * numerator / denominator;

    values.push_back(static_cast<T>(value));
  }

  return values;
}

} // namespace kprof::param

#endif // KPROF_PARAM_STORED_LINSPACE_HPP
