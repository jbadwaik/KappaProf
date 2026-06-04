// -------------------------------------------------------------------------------------------------
// SPDX-License-Identifier: Apache-2.0
// -------------------------------------------------------------------------------------------------

#ifndef KPROF_EXECUTOR_TIMER_DETAIL_MEAN_STD_HPP
#define KPROF_EXECUTOR_TIMER_DETAIL_MEAN_STD_HPP

namespace kprof::executor::timer::detail::mean_std {

struct result_type {
  double mean;
  double stddev;
};
} // namespace kprof::executor::timer::detail::mean_std

#endif // KPROF_EXECUTOR_TIMER_DETAIL_MEAN_STD_HPP
