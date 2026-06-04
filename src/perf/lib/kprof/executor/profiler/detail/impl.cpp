// -------------------------------------------------------------------------------------------------
// SPDX-License-Identifier: Apache-2.0
// -------------------------------------------------------------------------------------------------

#include <cerrno>
#include <kprof/executor/profiler/detail/perf/impl.hpp>
#include <sys/ioctl.h>
#include <sys/syscall.h>
#include <system_error>
#include <unistd.h>

namespace kprof::executor::profiler::detail::perf {

auto checked_ioctl(int fd, unsigned long request, const char* message) -> void
{
  if (ioctl(fd, request, 0) == -1) {
    throw std::system_error(errno, std::generic_category(), message);
  }
}

auto make_event_attr(counter counter) -> perf_event_attr
{
  perf_event_attr attr{};
  attr.size = sizeof(perf_event_attr);
  attr.disabled = 1;
  attr.exclude_kernel = 1;
  attr.exclude_hv = 1;

  switch (counter) {
  case counter::cycles:
    attr.type = PERF_TYPE_HARDWARE;
    attr.config = PERF_COUNT_HW_CPU_CYCLES;
    break;
  }

  return attr;
}

auto open_counter(const perf_event_attr& attr) -> int
{
  const auto fd = static_cast<int>(syscall(SYS_perf_event_open, &attr, 0, -1, -1, 0));

  if (fd == invalid_fd) {
    throw std::system_error(errno, std::generic_category(), "perf_event_open failed");
  }

  return fd;
}

auto start(const counter_vector& counters) -> event_vector
{
  event_vector events{};
  events.reserve(counters.size());

  for (const auto counter : counters) {
    const auto attr = make_event_attr(counter);
    const auto fd = open_counter(attr);

    try {
      checked_ioctl(fd, PERF_EVENT_IOC_RESET, "PERF_EVENT_IOC_RESET failed");
      checked_ioctl(fd, PERF_EVENT_IOC_ENABLE, "PERF_EVENT_IOC_ENABLE failed");

      events.emplace_back(counter, fd);
    }
    catch (...) {
      if (fd != invalid_fd) {
        close(fd);
      }

      throw;
    }
  }

  return events;
}

auto stop_and_read(const event_vector& events) -> result
{
  result result{};

  for (const auto& event : events) {
    checked_ioctl(event.native_handle(), PERF_EVENT_IOC_DISABLE, "PERF_EVENT_IOC_DISABLE failed");

    result::value_type value{};

    if (read(event.native_handle(), &value, sizeof(value)) != sizeof(value)) {
      throw std::system_error(errno, std::generic_category(), "reading perf counter failed");
    }

    result.insert(event.get_counter(), value);
  }

  return result;
}

} // namespace kprof::executor::profiler::detail::perf
