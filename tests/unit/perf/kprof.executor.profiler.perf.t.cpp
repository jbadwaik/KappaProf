// -------------------------------------------------------------------------------------------------
// SPDX-License-Identifier: Apache-2.0
// -------------------------------------------------------------------------------------------------

#include <catch2/catch_test_macros.hpp>
#include <cstdint>
#include <kprof/core.hpp>
#include <kprof/executor/profiler/detail/perf/impl.hpp>
#include <kprof/executor/profiler/detail/perf/types.hpp>
#include <kprof/executor/profiler/perf.hpp>
#include <kprof_devkit/catch2/main.hpp>
#include <linux/perf_event.h>
#include <stdexcept>
#include <system_error>

/* NOLINTNEXTLINE(cppcoreguidelines-avoid-non-const-global-variables)*/
KPROF_DEVKIT_CATCH2_MAIN("test/unit/cpp/kprof/executor/perf_profiler")

namespace {

using kprof::executor::profiler::perf;
using kprof::executor::profiler::detail::perf::counter;

auto perf_cycles_available() -> bool
{
  try {
    const auto attr = kprof::executor::profiler::detail::perf::make_event_attr(counter::cycles);
    const auto fd = kprof::executor::profiler::detail::perf::open_counter(attr);

    kprof::executor::profiler::detail::perf::event event{counter::cycles, fd};

    return true;
  }
  catch (const std::system_error& error) {
    UNSCOPED_INFO("perf cycles unavailable: " << error.what());
    return false;
  }
}

auto require_perf_cycles_available() -> void
{
  if (!perf_cycles_available()) {
    SKIP("perf cycles counter is not available on this system");
  }
}

auto small_workload() -> void
{
  std::uint64_t value = 0;

  for (std::uint64_t i = 0; i < 10000; ++i) {
    value += i;
  }

  kprof::core::do_not_optimize(value);
  UNSCOPED_INFO("small_workload value = " << value);
}

} // namespace

TEST_CASE("perf result starts empty")
{
  kprof::executor::profiler::detail::perf::result result;

  UNSCOPED_INFO("result size = " << result.size());

  REQUIRE(result.empty());
  REQUIRE(result.size() == 0);
  REQUIRE_FALSE(result.contains(counter::cycles));
}

TEST_CASE("perf result stores counter values")
{
  kprof::executor::profiler::detail::perf::result result;

  result.insert(counter::cycles, 42);

  UNSCOPED_INFO("cycles = " << result.value(counter::cycles));
  UNSCOPED_INFO("result size = " << result.size());

  REQUIRE_FALSE(result.empty());
  REQUIRE(result.size() == 1);
  REQUIRE(result.contains(counter::cycles));
  REQUIRE(result.value(counter::cycles) == 42);
}

TEST_CASE("perf result overwrites existing counter values")
{
  kprof::executor::profiler::detail::perf::result result;

  result.insert(counter::cycles, 42);
  result.insert(counter::cycles, 84);

  UNSCOPED_INFO("cycles = " << result.value(counter::cycles));
  UNSCOPED_INFO("result size = " << result.size());

  REQUIRE(result.size() == 1);
  REQUIRE(result.value(counter::cycles) == 84);
}

TEST_CASE("perf event attr maps cycles to Linux perf cycles counter")
{
  const auto attr = kprof::executor::profiler::detail::perf::make_event_attr(counter::cycles);

  UNSCOPED_INFO("attr.size = " << attr.size);
  UNSCOPED_INFO("attr.disabled = " << attr.disabled);
  UNSCOPED_INFO("attr.exclude_kernel = " << attr.exclude_kernel);
  UNSCOPED_INFO("attr.exclude_hv = " << attr.exclude_hv);
  UNSCOPED_INFO("attr.type = " << attr.type);
  UNSCOPED_INFO("attr.config = " << attr.config);

  REQUIRE(attr.size == sizeof(perf_event_attr));
  REQUIRE(attr.disabled == 1);
  REQUIRE(attr.exclude_kernel == 1);
  REQUIRE(attr.exclude_hv == 1);
  REQUIRE(attr.type == PERF_TYPE_HARDWARE);
  REQUIRE(attr.config == PERF_COUNT_HW_CPU_CYCLES);
}

TEST_CASE("perf requires at least one counter")
{
  REQUIRE_THROWS_AS(perf{perf::counter_vector_type{}}, std::invalid_argument);
}

TEST_CASE("perf can be constructed with cycles counter")
{
  REQUIRE_NOTHROW(perf{{counter::cycles}});
}

TEST_CASE("perf start creates one event per counter")
{
  require_perf_cycles_available();

  const auto events = kprof::executor::profiler::detail::perf::start({counter::cycles});

  UNSCOPED_INFO("events.size = " << events.size());

  REQUIRE(events.size() == 1);

  UNSCOPED_INFO("event native_handle = " << events.front().native_handle());

  REQUIRE(events.front().get_counter() == counter::cycles);
  REQUIRE(events.front().native_handle() != kprof::executor::profiler::detail::perf::invalid_fd);
}

TEST_CASE("perf stop_and_read returns a value for each started counter")
{
  require_perf_cycles_available();

  auto events = kprof::executor::profiler::detail::perf::start({counter::cycles});

  small_workload();

  const auto result = kprof::executor::profiler::detail::perf::stop_and_read(events);

  REQUIRE(result.contains(counter::cycles));

  const auto cycles = result.value(counter::cycles);
  UNSCOPED_INFO("cycles = " << cycles);

  REQUIRE(cycles > 0);
}

TEST_CASE("perf profiler measures cycles")
{
  require_perf_cycles_available();

  perf profiler{{counter::cycles}};

  const auto result = profiler([] { small_workload(); });

  REQUIRE(result.contains(counter::cycles));

  const auto cycles = result.value(counter::cycles);
  UNSCOPED_INFO("cycles = " << cycles);

  REQUIRE(cycles > 0);
}

TEST_CASE("perf profiler invokes function exactly once")
{
  require_perf_cycles_available();

  perf profiler{{counter::cycles}};

  int calls = 0;

  const auto result = profiler([&calls] { ++calls; });

  UNSCOPED_INFO("calls = " << calls);

  REQUIRE(calls == 1);
  REQUIRE(result.contains(counter::cycles));

  const auto cycles = result.value(counter::cycles);
  UNSCOPED_INFO("cycles = " << cycles);
}

TEST_CASE("perf profiler forwards arguments")
{
  require_perf_cycles_available();

  perf profiler{{counter::cycles}};

  int value = 0;

  const auto result = profiler([](int& target, int increment) { target += increment; }, value, 7);

  UNSCOPED_INFO("value = " << value);

  REQUIRE(value == 7);
  REQUIRE(result.contains(counter::cycles));

  const auto cycles = result.value(counter::cycles);
  UNSCOPED_INFO("cycles = " << cycles);
}

TEST_CASE("perf profiler propagates exceptions from measured function")
{
  require_perf_cycles_available();

  perf profiler{{counter::cycles}};

  REQUIRE_THROWS_AS(
    profiler([] { throw std::runtime_error{"measured function failed"}; }), std::runtime_error);
}
