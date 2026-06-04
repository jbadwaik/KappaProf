# --------------------------------------------------------------------------------------------------
# SPDX-License-Identifier: Apache-2.0 OR MIT
# --------------------------------------------------------------------------------------------------

add_library(libkprof_test INTERFACE)
target_link_libraries(libkprof_test INTERFACE kprof::libkprof)
target_link_libraries(libkprof_test INTERFACE libkprof_devkit)

add_subdirectory(unit)


