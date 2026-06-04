// -------------------------------------------------------------------------------------------------
// SPDX-License-Identifier: Apache-2.0
// -------------------------------------------------------------------------------------------------

#ifndef KPROF_SUPPORT_CATCH2_DATA_HPP
#define KPROF_SUPPORT_CATCH2_DATA_HPP

#include <string>

namespace kprof_devkit::catch2 {
class path {
public:
  path() = default;
  path(std::string input, std::string output);

public:
  auto input() const noexcept -> std::string const&;
  auto output() const noexcept -> std::string const&;

private:
  std::string input_;
  std::string output_;
};

auto path_from_prefix(path const& prefix, std::string const& suffix) -> path;
} // namespace kprof_devkit::catch2

#endif // KPROF_SUPPORT_CATCH2_DATA_HPP
