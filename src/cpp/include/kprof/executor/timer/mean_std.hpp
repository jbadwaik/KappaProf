// -------------------------------------------------------------------------------------------------
// SPDX-License-Identifier: Apache-2.0
// -------------------------------------------------------------------------------------------------

#ifndef KPROF_EXECUTOR_TIMER_MEAN_STD_TIMER_HPP
#define KPROF_EXECUTOR_TIMER_MEAN_STD_TIMER_HPP

#include <cmath>
#include <concepts>
#include <cstddef>
#include <kprof/executor/timer/detail/mean_std.hpp>
#include <utility>

namespace kprof::executor::timer {

template <typename SingleShot>
class mean_std {
public:
  using single_shot_timer_type = SingleShot;
  using result_type = detail::mean_std::result_type;

public:
  mean_std() = default;
  mean_std(single_shot_timer_type single_shot, std::size_t num_iterations)
  : num_iterations_(num_iterations), single_shot_timer_(std::move(single_shot))
  {
  }

public:
  template <typename F, typename... Args>
    requires std::invocable<F, Args...>
  [[nodiscard]] result_type operator()(F&& function, Args&&... args) const;

private:
  std::size_t num_iterations_ = 1;
  single_shot_timer_type single_shot_timer_;
};

template <typename SingleShot>
template <typename F, typename... Args>
  requires std::invocable<F, Args...>
auto mean_std<SingleShot>::operator()(F&& function, Args&&... args) const -> result_type
{
  double mean = 0.0;
  double m2 = 0.0;

  for (std::size_t i = 0; i < num_iterations_; ++i) {
    const auto runtime = single_shot_timer_(std::forward<F>(function), std::forward<Args>(args)...);

    const auto x = static_cast<double>(runtime.count());
    const auto n = static_cast<double>(i + 1);

    const auto delta = x - mean;
    mean += delta / n;

    const auto delta2 = x - mean;
    m2 += delta * delta2;
  }

  return result_type{
    .mean = mean,
    .stddev = num_iterations_ > 0 ? std::sqrt(m2 / static_cast<double>(num_iterations_)) : 0.0,
  };
}
} // namespace kprof::executor::timer

#endif // KPROF_EXECUTOR_TIMER_MEAN_STD_TIMER_HPP
