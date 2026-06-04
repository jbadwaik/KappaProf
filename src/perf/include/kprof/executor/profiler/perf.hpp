// -------------------------------------------------------------------------------------------------
// SPDX-License-Identifier: Apache-2.0
// -------------------------------------------------------------------------------------------------

#ifndef KPROF_EXECUTOR_PROFILER_PERF_HPP
#define KPROF_EXECUTOR_PROFILER_PERF_HPP

#include <concepts>
#include <functional>
#include <kprof/executor/profiler/detail/perf/types.hpp>
#include <utility>

namespace kprof::executor::profiler {

class perf {
public:
  using counter_type = detail::perf::counter;
  using counter_vector_type = detail::perf::counter_vector;
  using result_type = detail::perf::result;

public:
  explicit perf(counter_vector_type counters = {counter_type::cycles});

  template <typename F, typename... Args>
    requires std::invocable<F, Args...>
  [[nodiscard]] auto operator()(F&& function, Args&&... args) const -> result_type;

private:
  counter_vector_type counters_;
};

[[nodiscard]] auto perf_start(const detail::perf::counter_vector& counters)
  -> detail::perf::event_vector;

[[nodiscard]] auto perf_stop_and_read(const detail::perf::event_vector& events)
  -> detail::perf::result;

template <typename F, typename... Args>
  requires std::invocable<F, Args...>
auto perf::operator()(F&& function, Args&&... args) const -> result_type
{
  auto events = perf_start(counters_);

  std::invoke(std::forward<F>(function), std::forward<Args>(args)...);

  return perf_stop_and_read(events);
}

} // namespace kprof::executor::profiler
#endif // KPROF_EXECUTOR_PROFILER_PERF_HPP
