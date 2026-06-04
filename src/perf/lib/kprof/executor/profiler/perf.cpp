// -------------------------------------------------------------------------------------------------
// SPDX-License-Identifier: Apache-2.0
// -------------------------------------------------------------------------------------------------

#include <kprof/executor/profiler/detail/perf/impl.hpp>
#include <kprof/executor/profiler/perf.hpp>

#include <stdexcept>
#include <utility>

namespace kprof::executor::profiler {

perf::perf(counter_vector_type counters) : counters_(std::move(counters))
{
  if (counters_.empty()) {
    throw std::invalid_argument("perf requires at least one counter");
  }
}

auto perf_start(const detail::perf::counter_vector& counters) -> detail::perf::event_vector
{
  return detail::perf::start(counters);
}

auto perf_stop_and_read(const detail::perf::event_vector& events) -> detail::perf::result
{
  return detail::perf::stop_and_read(events);
}

} // namespace kprof::executor::profiler
