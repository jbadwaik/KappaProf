// -------------------------------------------------------------------------------------------------
// SPDX-License-Identifier: Apache-2.0
// -------------------------------------------------------------------------------------------------
#include <catch2/catch_test_macros.hpp>
#include <thread>

#include <kprof/executor/timer/single_shot.hpp>
#include <kprof_devkit/catch2/main.hpp>

/* NOLINTNEXTLINE(cppcoreguidelines-avoid-non-const-global-variables)*/
KPROF_DEVKIT_CATCH2_MAIN("test/unit/cpp/kprof/executor/single_shot_timer")

TEST_CASE("single_shot_timer measures runtime")
{
  using namespace std::chrono_literals;

  kprof::executor::timer::single_shot timer;

  for (int i = 0; i < 100; ++i) {
    const auto runtime = timer([] { std::this_thread::sleep_for(1ms); });

    REQUIRE(runtime >= 1ms);

    // Loose upper bound for CI / scheduler jitter.
    REQUIRE(runtime < 100ms);
  }
}
