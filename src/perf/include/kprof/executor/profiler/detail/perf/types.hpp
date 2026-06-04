// -------------------------------------------------------------------------------------------------
// SPDX-License-Identifier: Apache-2.0
// -------------------------------------------------------------------------------------------------

#ifndef KPROF_EXECUTOR_PROFILER_PERF_TYPES_HPP
#define KPROF_EXECUTOR_PROFILER_PERF_TYPES_HPP

#include <cstdint>
#include <map>
#include <vector>

namespace kprof::executor::profiler::detail::perf {

inline constexpr auto invalid_fd = -1;

enum class counter {
  cycles = 1,
};

class result {
public:
  using counter_type = counter;
  using value_type = std::uint64_t;
  using map_type = std::map<counter_type, value_type>;
  using const_iterator = map_type::const_iterator;

public:
  result() = default;

  [[nodiscard]] auto contains(counter_type counter) const -> bool;
  [[nodiscard]] auto value(counter_type counter) const -> value_type;
  [[nodiscard]] auto size() const -> map_type::size_type;
  [[nodiscard]] auto empty() const -> bool;

  [[nodiscard]] auto begin() const -> const_iterator;
  [[nodiscard]] auto end() const -> const_iterator;

  auto insert(counter_type counter, value_type value) -> void;

private:
  map_type values_{};
};

class event {
public:
  using native_handle_type = int;

public:
  event(counter counter, native_handle_type fd);
  ~event();

  event(const event&) = delete;
  auto operator=(const event&) -> event& = delete;

  event(event&& other) noexcept;
  auto operator=(event&& other) noexcept -> event&;

  [[nodiscard]] auto get_counter() const -> counter;
  [[nodiscard]] auto native_handle() const -> native_handle_type;

private:
  counter counter_;
  native_handle_type fd_;
};

using counter_vector = std::vector<counter>;
using event_vector = std::vector<event>;

} // namespace kprof::executor::profiler::detail::perf
#endif // KPROF_EXECUTOR_PROFILER_PERF_TYPES_HPP
