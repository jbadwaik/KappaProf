// -------------------------------------------------------------------------------------------------
// SPDX-License-Identifier: Apache-2.0
// -------------------------------------------------------------------------------------------------

#include <catch2/catch_test_macros.hpp>
#include <kprof_devkit/catch2/main.hpp>

/* NOLINTNEXTLINE(cppcoreguidelines-avoid-non-const-global-variables)*/
KPROF_DEVKIT_CATCH2_MAIN("test/unit/cpp/kprof_test/self")

// NOLINTNEXTLINE(cppcoreguidelines-avoid-non-const-global-variables)
TEST_CASE("Main: Dummy", "[all]")
{
  REQUIRE(1 == 1);
}
