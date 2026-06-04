// -------------------------------------------------------------------------------------------------
// SPDX-License-Identifier: Apache-2.0
// -------------------------------------------------------------------------------------------------

#ifndef KPROF_DEVKIT_CATCH2_MAIN_HPP
#define KPROF_DEVKIT_CATCH2_MAIN_HPP

#include <kprof_devkit/catch2/data.hpp>
#include <kprof_devkit/catch2/runner.hpp>

// NOLINTNEXTLINE(cppcoreguidelines-macro-usage)
#define KPROF_DEVKIT_CATCH2_MAIN(suffix)                                                           \
                                                                                                   \
  /* NOLINTNEXTLINE(cppcoreguidelines-avoid-non-const-global-variables)*/                          \
  extern kprof_devkit::catch2::path project_prefix;                                                \
  /* NOLINTNEXTLINE(cppcoreguidelines-avoid-non-const-global-variables)*/                          \
  extern kprof_devkit::catch2::path group_prefix;                                                  \
                                                                                                   \
  /* path_prefix : Paths Corresponding to the Complete Project */                                  \
  /* NOLINTNEXTLINE(cppcoreguidelines-avoid-non-const-global-variables)*/                          \
  kprof_devkit::catch2::path project_prefix = kprof_devkit::catch2::path();                        \
  /* path_prefix : Paths Corresponding to The Current Group */                                     \
  /* NOLINTNEXTLINE(cppcoreguidelines-avoid-non-const-global-variables)*/                          \
  kprof_devkit::catch2::path group_prefix = kprof_devkit::catch2::path();                          \
                                                                                                   \
  auto main(int argc, char* argv[]) -> int                                                         \
  {                                                                                                \
    return kprof_devkit::catch2::runner(                                                           \
      argc, argv, &project_prefix, &group_prefix, std::string(suffix));                            \
  }

// NOLINTNEXTLINE(cppcoreguidelines-macro-usage)
#define KPROF_DEVKIT_CATCH2_GROUP()                                                                \
                                                                                                   \
  /* NOLINTNEXTLINE(cppcoreguidelines-avoid-non-const-global-variables)*/                          \
  extern kprof_devkit::catch2::path project_prefix;                                                \
  /* NOLINTNEXTLINE(cppcoreguidelines-avoid-non-const-global-variables)*/                          \
  extern kprof_devkit::catch2::path group_prefix;

#endif // KPROF_DEVKIT_CATCH2_MAIN_HPP
