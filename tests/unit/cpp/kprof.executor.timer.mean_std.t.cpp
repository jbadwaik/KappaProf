// -------------------------------------------------------------------------------------------------
// SPDX-License-Identifier: Apache-2.0
// -------------------------------------------------------------------------------------------------
#include <catch2/catch_test_macros.hpp>
#include <chrono>
#include <thread>

#include <kprof/executor/timer/mean_std.hpp>
#include <kprof/executor/timer/single_shot.hpp>
#include <kprof_devkit/catch2/main.hpp>

/* NOLINTNEXTLINE(cppcoreguidelines-avoid-non-const-global-variables)*/
KPROF_DEVKIT_CATCH2_MAIN("test/unit/cpp/kprof/executor/mean_std_timer")

TEST_CASE("mean_std_timer measures mean and standard deviation")
{
  using namespace std::chrono_literals;

  using single_shot_timer_type = kprof::executor::timer::single_shot;

  auto timer = kprof::executor::timer::mean_std<kprof::executor::timer::single_shot>(
    single_shot_timer_type{}, 10);

  const auto result = timer([] { std::this_thread::sleep_for(1ms); });

  CAPTURE(result.mean, result.stddev);

  const auto min_runtime = static_cast<double>(
    std::chrono::duration_cast<single_shot_timer_type::duration_type>(1ms).count());

  const auto max_runtime = static_cast<double>(
    std::chrono::duration_cast<single_shot_timer_type::duration_type>(100ms).count());

  REQUIRE(result.mean >= min_runtime);
  REQUIRE(result.mean < max_runtime);

  REQUIRE(result.stddev >= 0.0);
  REQUIRE(result.stddev < max_runtime);
}
