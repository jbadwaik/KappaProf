// -------------------------------------------------------------------------------------------------
// SPDX-License-Identifier: Apache-2.0
// -------------------------------------------------------------------------------------------------

#ifndef KPROF_EXECUTOR_PROFILER_DETAIL_PERF_IMPL_HPP
#define KPROF_EXECUTOR_PROFILER_DETAIL_PERF_IMPL_HPP

#include <kprof/executor/profiler/detail/perf/types.hpp>
#include <linux/perf_event.h>

namespace kprof::executor::profiler::detail::perf {

auto checked_ioctl(int fd, unsigned long request, const char* message) -> void;

[[nodiscard]] auto make_event_attr(counter counter) -> perf_event_attr;

[[nodiscard]] auto open_counter(const perf_event_attr& attr) -> int;

[[nodiscard]] auto start(const counter_vector& counters) -> event_vector;

[[nodiscard]] auto stop_and_read(const event_vector& events) -> result;

} // namespace kprof::executor::profiler::detail::perf
#endif // KPROF_EXECUTOR_PROFILER_DETAIL_PERF_IMPL_HPP
