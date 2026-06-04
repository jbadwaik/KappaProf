// -------------------------------------------------------------------------------------------------
// SPDX-License-Identifier: Apache-2.0
// -------------------------------------------------------------------------------------------------

#ifndef KPROF_EXECUTOR_TIMER_SINGLE_SHOT_HPP
#define KPROF_EXECUTOR_TIMER_SINGLE_SHOT_HPP

#include <chrono>
#include <functional>

namespace kprof::executor::timer {

class single_shot {
public:
  using clock_type = std::chrono::steady_clock;
  using duration_type = clock_type::duration;

  template <typename F, typename... Args>
    requires std::invocable<F, Args...>
  [[nodiscard]] duration_type operator()(F&& function, Args&&... args) const;
};

template <typename F, typename... Args>
  requires std::invocable<F, Args...>
auto single_shot::operator()(F&& function, Args&&... args) const -> duration_type
{
  const auto start = clock_type::now();
  std::invoke(std::forward<F>(function), std::forward<Args>(args)...);
  const auto stop = clock_type::now();

  return stop - start;
}

} // namespace kprof::executor::timer

#endif // KPROF_EXECUTOR_TIMER_SINGLE_SHOT_HPP
