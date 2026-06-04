// -------------------------------------------------------------------------------------------------
// SPDX-License-Identifier: Apache-2.0
// -------------------------------------------------------------------------------------------------

#ifndef KPROF_DEVKIT_CATCH2_CMDLINE_HPP
#define KPROF_DEVKIT_CATCH2_CMDLINE_HPP

#include <kprof_devkit/catch2/data.hpp>
#include <memory>
#include <string>
#include <vector>

namespace kprof_devkit::catch2 {
class result {
public:
  result() = default;
  result(::kprof_devkit::catch2::path path, std::vector<std::string> cmdline)
  : path_(std::move(path)), cmdline_(std::move(cmdline))
  {
  }

public:
  auto path() const noexcept -> ::kprof_devkit::catch2::path const& { return path_; }
  auto residual() const noexcept -> std::vector<std::string> const& { return cmdline_; }

private:
  kprof_devkit::catch2::path path_;
  std::vector<std::string> cmdline_;
};

auto parse(int argc, char** argv) -> result;
// NOLINTNEXTLINE(modernize-avoid-c-arrays)
auto to_native_view(std::vector<std::string> const& cmdline) -> std::unique_ptr<char*[]>;
} // namespace kprof_devkit::catch2

#endif // KPROF_DEVKIT_CATCH2_CMDLINE_HPP
