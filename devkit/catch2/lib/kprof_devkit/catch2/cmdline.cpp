// -------------------------------------------------------------------------------------------------
// SPDX-License-Identifier: Apache-2.0
// -------------------------------------------------------------------------------------------------

#include <algorithm>
#include <cstddef>
#include <iterator>
#include <kprof_devkit/catch2/cmdline.hpp>
#include <memory>
#include <stdexcept>
#include <vector>

namespace kprof_devkit::catch2 {
auto parse(int argc, char** argv) -> result
{
  auto arg_array = std::vector<std::string>(argv, argv + argc);
  auto const argc_size_t = std::size(arg_array);

  bool input_specified = false;
  bool output_specified = false;

  std::string input;

  std::string output;

  std::size_t i = 0;
  while (i < argc_size_t) {
    auto const& key = arg_array[i];
    if (key == "--input") {
      ++i;
      if (i == argc_size_t) {
        throw std::runtime_error("Expected an Argument to --input");
      }
      input = arg_array[i];
      input_specified = true;
    }
    else if (key == "--output") {
      ++i;
      if (i == argc_size_t) {
        throw std::runtime_error("Expected an Argument to --output");
      }
      output = arg_array[i];
      output_specified = true;
    }
    ++i;
  }

  if ((not input_specified)) {
    throw std::runtime_error("Input not specified");
  }

  if ((not output_specified)) {
    throw std::runtime_error("Output not specified");
  }

  auto const input_it = std::find(arg_array.begin(), arg_array.end(), std::string("--input"));
  arg_array.erase(input_it, input_it + 2);

  auto const output_it = std::find(arg_array.begin(), arg_array.end(), std::string("--output"));
  arg_array.erase(output_it, output_it + 2);

  auto const data = kprof_devkit::catch2::path(input, output);

  return {data, arg_array};
}

// NOLINTNEXTLINE(modernize-avoid-c-arrays)
auto to_native_view(std::vector<std::string> const& cmdline) -> std::unique_ptr<char*[]>
{
  // NOLINTNEXTLINE(modernize-avoid-c-arrays)
  auto view = std::make_unique<char*[]>(cmdline.size());
  for (std::size_t i = 0; i < cmdline.size(); ++i) {
    // NOLINTNEXTLINE(cppcoreguidelines-pro-type-const-cast)
    view[i] = const_cast<char*>(cmdline[i].data());
  }
  return view;
}
} // namespace kprof_devkit::catch2
