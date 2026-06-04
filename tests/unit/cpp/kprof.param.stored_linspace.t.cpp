// -------------------------------------------------------------------------------------------------
// SPDX-License-Identifier: Apache-2.0
// -------------------------------------------------------------------------------------------------

#include <algorithm>
#include <catch2/catch_test_macros.hpp>
#include <kprof/exception.hpp>
#include <kprof/param/stored_linspace.hpp>
#include <kprof_devkit/catch2/main.hpp>
#include <vector>

/* NOLINTNEXTLINE(cppcoreguidelines-avoid-non-const-global-variables)*/
KPROF_DEVKIT_CATCH2_MAIN("test/unit/cpp/kprof/param/stored_linspace")

TEST_CASE("stored_linspace satisfies parameter concepts")
{
  static_assert(kprof::param::space<kprof::param::stored_linspace<int>>);
  static_assert(kprof::param::sized_space<kprof::param::stored_linspace<int>>);
  static_assert(kprof::param::indexed_space<kprof::param::stored_linspace<int>>);
  static_assert(kprof::param::source<kprof::param::stored_linspace<int>>);
}

TEST_CASE("stored_linspace creates evenly spaced integral values")
{
  kprof::param::stored_linspace<int> values{0, 10, 6};

  const std::vector<int> expected{0, 2, 4, 6, 8, 10};

  REQUIRE(values.size() == expected.size());
  REQUIRE(std::ranges::equal(values, expected));
}

TEST_CASE("stored_linspace supports descending values")
{
  kprof::param::stored_linspace<int> values{10, 0, 6};

  const std::vector<int> expected{10, 8, 6, 4, 2, 0};

  REQUIRE(values.size() == expected.size());
  REQUIRE(std::ranges::equal(values, expected));
}

TEST_CASE("stored_linspace with count zero is empty")
{
  kprof::param::stored_linspace<int> values{0, 10, 0};

  REQUIRE(values.empty());
  REQUIRE(values.size() == 0);
  REQUIRE(values.begin() == values.end());
  REQUIRE(values.next() == std::nullopt);
}

TEST_CASE("stored_linspace with count one contains first value only")
{
  kprof::param::stored_linspace<int> values{7, 99, 1};

  const std::vector<int> expected{7};

  REQUIRE(values.size() == 1);
  REQUIRE(std::ranges::equal(values, expected));
}

TEST_CASE("stored_linspace rejects non-integral spacing")
{
  REQUIRE_THROWS_AS(
    (kprof::param::stored_linspace<int>{0, 10, 4}), kprof::exception::invalid_argument);
}

TEST_CASE("stored_linspace next returns values and then nullopt")
{
  kprof::param::stored_linspace<int> values{0, 4, 3};

  REQUIRE(values.next() == std::optional<int>{0});
  REQUIRE(values.next() == std::optional<int>{2});
  REQUIRE(values.next() == std::optional<int>{4});
  REQUIRE(values.next() == std::nullopt);
  REQUIRE(values.next() == std::nullopt);
}

TEST_CASE("stored_linspace reset restarts source iteration")
{
  kprof::param::stored_linspace<int> values{0, 4, 3};

  REQUIRE(values.next() == std::optional<int>{0});
  REQUIRE(values.next() == std::optional<int>{2});

  values.reset();

  REQUIRE(values.next() == std::optional<int>{0});
  REQUIRE(values.next() == std::optional<int>{2});
  REQUIRE(values.next() == std::optional<int>{4});
  REQUIRE(values.next() == std::nullopt);
}
