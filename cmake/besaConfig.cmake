# --------------------------------------------------------------------------------------------------
# SPDX-License-Identifier: Apache-2.0
# Copyright (C) 2024 Jayesh Badwaik <j.badwaik@fz-juelich.de>
# --------------------------------------------------------------------------------------------------
include(CMakePushCheckState)
cmake_push_check_state()

set(BESA_BINARY_PATH_ARRAY ${CMAKE_SYSTEM_PREFIX_PATH})
list(PREPEND BESA_BINARY_PATH_ARRAY ${CMAKE_PREFIX_PATH})
list(TRANSFORM BESA_BINARY_PATH_ARRAY APPEND "/bin")


set(CMAKE_REQUIRED_QUIET ${besa_FIND_QUIETLY})
set(want_components ${besa_FIND_COMPONENTS})
set(extra_components ${want_components})

list(
  REMOVE_ITEM
  extra_components
  asan
  builder
  coverage
  doxygen
  feature
  format
  lsan
  mode
  surrogate
  test
  ubsan
  test
  tidy
  version
  warning
  )

foreach(component IN LISTS extra_components)
  message(FATAL_ERROR "Invalid find_package component for besa: ${component}")
endforeach()

foreach(component IN LISTS want_components)
  include(${CMAKE_CURRENT_LIST_DIR}/${component}.cmake)
endforeach()

cmake_pop_check_state()
