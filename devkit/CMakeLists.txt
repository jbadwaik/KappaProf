# --------------------------------------------------------------------------------------------------
# SPDX-License-Identifier: Apache-2.0
# --------------------------------------------------------------------------------------------------





if(PROJECT_DEVKITS_CATCH2)
  add_subdirectory(catch2)
  target_link_libraries(libkprof_devkit PUBLIC kprof::libkprof Catch2::Catch2)
endif()

