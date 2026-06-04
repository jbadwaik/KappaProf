# --------------------------------------------------------------------------------------------------
# SPDX-License-Identifier: Apache-2.0
# Copyright (C) 2024 Jayesh Badwaik <j.badwaik@fz-juelich.de>
# --------------------------------------------------------------------------------------------------
include_guard(GLOBAL)

function(besa_add_clang_tidy TESTNAME)
  message(STATUS "CMAKE_CXX_COMPILER_ID = ${CMAKE_CXX_COMPILER_ID}")
  if (NOT(${CMAKE_CXX_COMPILER_ID} STREQUAL "Clang"))
    message(FATAL_ERROR "Clang Tidy is only supported with Clang Compiler")
  endif()

  set(BESA_CLANG_TIDY_PASSTHROUGH "" CACHE STRING
    "Passthrough Arguments for Clang Tidy")

  find_program(BESA_RUN_CLANG_TIDY run-clang-tidy REQUIRED NO_DEFAULT_PATH
    PATHS ${BESA_BINARY_PATH_ARRAY} DOC "run-clang-tidy executable")

  find_program(BESA_CLANG_TIDY clang-tidy REQUIRED NO_DEFAULT_PATH
    PATHS ${BESA_BINARY_PATH_ARRAY} DOC "clang-tidy executable")

  add_test(
    NAME ${TESTNAME}
    COMMAND ${BESA_RUN_CLANG_TIDY}
    -clang-tidy-binary ${BESA_CLANG_TIDY}
    -extra-arg=${BESA_CLANG_TIDY_PASSTHROUGH}
    -p ${PROJECT_BINARY_DIR}
    WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
    )
endfunction()
