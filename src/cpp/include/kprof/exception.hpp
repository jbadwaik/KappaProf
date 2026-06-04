// -------------------------------------------------------------------------------------------------
// SPDX-License-Identifier: Apache-2.0
// -------------------------------------------------------------------------------------------------

#ifndef KPROF_ERROR_HPP
#define KPROF_ERROR_HPP

#include <stdexcept>
#include <string>

namespace kprof::exception {

class base : public std::runtime_error {
public:
  explicit base(std::string message) : std::runtime_error(std::move(message)) {}
};

class invalid_argument : public base {
public:
  explicit invalid_argument(std::string message) : base(std::move(message)) {}
};

} // namespace kprof::exception

#endif // KPROF_ERROR_HPP
