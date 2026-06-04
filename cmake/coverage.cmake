# --------------------------------------------------------------------------------------------------
# SPDX-License-Identifier: Apache-2.0
# Copyright (C) 2024 Jayesh Badwaik <j.badwaik@fz-juelich.de>
# --------------------------------------------------------------------------------------------------
include_guard(GLOBAL)

set(BESA_COVERAGE_OUTDIR ${PROJECT_BINARY_DIR}/coverage
  CACHE PATH "Path to Store Output of Coverage Data")

add_library(besa::coverage INTERFACE IMPORTED)

if(BESA_COVERAGE_ENABLED)
  add_custom_target(besa.coverage)

  add_test(
    NAME besa.coverage.t
    COMMAND ${CMAKE_COMMAND} --build . --target besa.coverage --config $<CONFIG>
    WORKING_DIRECTORY ${PROJECT_BINARY_DIR})

  set(BESA_COVERAGE_GROUP_ARRAY CACHE INTERNAL "List of Coverage Groups")

  if(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
    include(${CMAKE_CURRENT_LIST_DIR}/coverage/clang.cmake)
  elseif(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    include(${CMAKE_CURRENT_LIST_DIR}/coverage/gcc.cmake)
  else()
    message(FATAL_ERROR "besa coverage doesn't support compiler: ${CMAKE_CXX_COMPILER_ID}")
  endif()

  include(${CMAKE_CURRENT_LIST_DIR}/coverage/common.after.cmake)

  cmake_language(
    EVAL CODE "cmake_language(DEFER DIRECTORY ${PROJECT_SOURCE_DIR} CALL besa_coverage_process)")
else()
  include(${CMAKE_CURRENT_LIST_DIR}/coverage/dummy.cmake)
endif()
