// -------------------------------------------------------------------------------------------------
// SPDX-License-Identifier: Apache-2.0
// -------------------------------------------------------------------------------------------------

#include <iostream>
#include <kprof/core.hpp>
#include <kprof/executor/profiler/perf.hpp>
#include <vector>

struct kernel_run_options {
  std::size_t size;
  std::size_t runs;
  std::size_t unroll;
};

template <typename T>
class vadd {

public:
  vadd() = default;

  vadd(std::vector<T> a, std::vector<T> b, std::vector<T> c)
  : a_(std::move(a)), b_(std::move(b)), c_(std::move(c))
  {
  }

private:
  std::vector<T> a_;
  std::vector<T> b_;
  std::vector<T> c_;

public:
  void operator()(kernel_run_options options)
  {
    T* __restrict__ a = a_.data();
    T* __restrict__ b = b_.data();
    T* __restrict__ c = c_.data();

    std::size_t elements = a_.size();

    for (unsigned long long i = 0; i < options.runs; i++) {
      switch (options.unroll) {
      case 1:
        for (unsigned long s = 0; s < elements; s += 1)
          c[s + 0] = a[s + 0] + b[s + 0];
        break;
      case 2:
        for (unsigned long s = 0; s < elements; s += 2) {
          c[s + 0] = a[s + 0] + b[s + 0];
          c[s + 1] = a[s + 1] + b[s + 1];
        }
        break;
      case 4:
        for (unsigned long s = 0; s < elements; s += 4) {
          c[s + 0] = a[s + 0] + b[s + 0];
          c[s + 1] = a[s + 1] + b[s + 1];
          c[s + 2] = a[s + 2] + b[s + 2];
          c[s + 3] = a[s + 3] + b[s + 3];
        }
        break;
      case 8:
      default:
        for (unsigned long s = 0; s < elements; s += 8) {
          c[s + 0] = a[s + 0] + b[s + 0];
          c[s + 1] = a[s + 1] + b[s + 1];
          c[s + 2] = a[s + 2] + b[s + 2];
          c[s + 3] = a[s + 3] + b[s + 3];
          c[s + 4] = a[s + 4] + b[s + 4];
          c[s + 5] = a[s + 5] + b[s + 5];
          c[s + 6] = a[s + 6] + b[s + 6];
          c[s + 7] = a[s + 7] + b[s + 7];
        }
        break;
      }
    }
    kprof::core::do_not_optimize(c);
  }
};

auto main() -> int
{
  std::size_t size = 1024 * 1024;
  std::vector<float> a(size, 1.0f);
  std::vector<float> b(size, 2.0f);
  std::vector<float> c(size, 0.0f);

  vadd<float> kernel{a, b, c};

  auto options = kernel_run_options{size, 1000, 4};

  auto profiler
    = kprof::executor::profiler::perf{{kprof::executor::profiler::perf::counter_type::cycles}};

  const auto result = profiler(kernel, options);

  std::cout << "Cycles: " << result.value(kprof::executor::profiler::perf::counter_type::cycles)
            << std::endl;

  return 0;
}
