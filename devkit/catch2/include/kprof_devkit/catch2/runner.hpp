// -------------------------------------------------------------------------------------------------
// SPDX-License-Identifier: Apache-2.0
// -------------------------------------------------------------------------------------------------

#ifndef KPROF_DEVKIT_CATCH2_RUNNER_HPP
#define KPROF_DEVKIT_CATCH2_RUNNER_HPP

#include <kprof_devkit/catch2/data.hpp>

namespace kprof_devkit::catch2 {
auto runner(
  int argc, char** argv, path* project_prefix, path* group_prefix, std::string const& suffix)
  -> int;

} // namespace kprof_devkit::catch2

#endif // KPROF_DEVKIT_CATCH2_RUNNER_HPP
