// -------------------------------------------------------------------------------------------------
// SPDX-License-Identifier: Apache-2.0
// -------------------------------------------------------------------------------------------------

#include <kprof/executor/profiler/detail/perf/types.hpp>
#include <unistd.h>
#include <utility>

namespace kprof::executor::profiler::detail::perf {

auto result::contains(counter_type counter) const -> bool
{
  return values_.contains(counter);
}

auto result::value(counter_type counter) const -> value_type
{
  return values_.at(counter);
}

auto result::size() const -> map_type::size_type
{
  return values_.size();
}

auto result::empty() const -> bool
{
  return values_.empty();
}

auto result::begin() const -> const_iterator
{
  return values_.begin();
}

auto result::end() const -> const_iterator
{
  return values_.end();
}

auto result::insert(counter_type counter, value_type value) -> void
{
  values_.insert_or_assign(counter, value);
}

event::event(counter counter, native_handle_type fd) : counter_(counter), fd_(fd)
{
}

event::~event()
{
  if (fd_ != invalid_fd) {
    close(fd_);
  }
}

event::event(event&& other) noexcept
: counter_(other.counter_), fd_(std::exchange(other.fd_, invalid_fd))
{
}

auto event::operator=(event&& other) noexcept -> event&
{
  if (this != &other) {
    if (fd_ != invalid_fd) {
      close(fd_);
    }

    counter_ = other.counter_;
    fd_ = std::exchange(other.fd_, invalid_fd);
  }

  return *this;
}

auto event::get_counter() const -> counter
{
  return counter_;
}

auto event::native_handle() const -> native_handle_type
{
  return fd_;
}

} // namespace kprof::executor::profiler::detail::perf
