// -------------------------------------------------------------------------------------------------
// SPDX-License-Identifier: Apache-2.0
// -------------------------------------------------------------------------------------------------

#include <kprof_devkit/catch2/data.hpp>

namespace kprof_devkit::catch2 {
path::path(std::string input, std::string output)
: input_(std::move(input)), output_(std::move(output))
{
}

auto path::input() const noexcept -> std::string const&
{
  return input_;
}

auto path::output() const noexcept -> std::string const&
{
  return output_;
}

auto path_from_prefix(path const& prefix, std::string const& suffix) -> path
{
  return {prefix.input() + std::string("/") + suffix, prefix.output() + std::string("/") + suffix};
}

} // namespace kprof_devkit::catch2
