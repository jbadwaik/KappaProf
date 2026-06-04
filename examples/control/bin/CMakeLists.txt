# --------------------------------------------------------------------------------------------------
# SPDX-License-Identifier: Apache-2.0
# --------------------------------------------------------------------------------------------------


add_executable(example.control.vadd vadd.cpp)
target_link_libraries(example.control.vadd PUBLIC libkprof)
