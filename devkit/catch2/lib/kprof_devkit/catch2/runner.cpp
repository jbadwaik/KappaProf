// -------------------------------------------------------------------------------------------------
// SPDX-License-Identifier: Apache-2.0
// -------------------------------------------------------------------------------------------------
#include <catch2/catch_session.hpp>
#include <kprof_devkit/catch2/cmdline.hpp>
#include <kprof_devkit/catch2/data.hpp>
#include <kprof_devkit/catch2/runner.hpp>

namespace kprof_devkit::catch2 {
auto runner(
  int argc, char** argv, path* project_prefix, path* group_prefix, std::string const& suffix) -> int
{
  auto result = parse(argc, argv);

  *project_prefix = kprof_devkit::catch2::path(result.path());
  *group_prefix = kprof_devkit::catch2::path_from_prefix(*project_prefix, suffix);

  int const residual_argc = static_cast<int>(result.residual().size());
  auto const residual_argv = to_native_view(result.residual());

  Catch::Session session;

  auto cli = session.cli();

  session.cli(cli);

  int const return_code = session.applyCommandLine(residual_argc, residual_argv.get());
  if (return_code != 0) {
    return return_code;
  }

  return session.run();
}

} // namespace kprof_devkit::catch2
