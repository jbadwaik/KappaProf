// -------------------------------------------------------------------------------------------------
// SPDX-License-Identifier: Apache-2.0
// -------------------------------------------------------------------------------------------------

#ifndef KPROF_CORE_HPP
#define KPROF_CORE_HPP

namespace kprof::core {
template <typename T>
auto do_not_optimize(const T& value) -> void
{
  asm volatile("" : : "g"(value) : "memory");
}
} // namespace kprof::core

#endif // KPROF_CORE_HPP
