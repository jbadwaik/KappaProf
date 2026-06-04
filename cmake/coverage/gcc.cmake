# --------------------------------------------------------------------------------------------------
# SPDX-License-Identifier: Apache-2.0
# Copyright (C) 2024 Jayesh Badwaik <j.badwaik@fz-juelich.de>
# --------------------------------------------------------------------------------------------------
include_guard(GLOBAL)

if(NOT CMAKE_CXX_COMPILER_ID STREQUAL CMAKE_C_COMPILER_ID)
  message(FATAL_ERROR "Coverage needs C and C++ Compilers to be identical.")
endif()

target_compile_options(besa::coverage INTERFACE
  $<$<COMPILE_LANGUAGE:C>:-fprofile-arcs>
  $<$<COMPILE_LANGUAGE:C>:-ftest-coverage>
  $<$<COMPILE_LANGUAGE:C>:-fprofile-update=atomic>
  $<$<COMPILE_LANGUAGE:CXX>:-fprofile-arcs>
  $<$<COMPILE_LANGUAGE:CXX>:-ftest-coverage>
  $<$<COMPILE_LANGUAGE:CXX>:-fprofile-update=atomic>
  )

target_link_options(besa::coverage INTERFACE --coverage)

find_program(BESA_LCOV lcov REQUIRED NO_DEFAULT_PATH
  PATHS ${BESA_BINARY_PATH_ARRAY} DOC "lcov executable")

find_program(BESA_GCOVR gcovr REQUIRED NO_DEFAULT_PATH
  PATHS ${BESA_BINARY_PATH_ARRAY} DOC "gcovr executable")

find_program(BESA_GENHTML genhtml REQUIRED NO_DEFAULT_PATH
  PATHS ${BESA_BINARY_PATH_ARRAY} DOC "genhtml executable")

function(besa_coverage_process_group_impl GROUP_NAME)
  add_custom_command(
    OUTPUT ${GROUP_NAME}.info
    WORKING_DIRECTORY ${BESA_COVERAGE_${GROUP_NAME}_OUTDIR}
    COMMAND
    ${CMAKE_COMMAND} -DCOVERAGE_OUTDIR=${BESA_COVERAGE_${GROUP_NAME}_OUTDIR}
    -DGROUP_NAME=${GROUP_NAME} -DBESA_LCOV=${BESA_LCOV}
    -DBESA_GCOVR=${BESA_GCOVR} -DSOURCE_DIR=${PROJECT_SOURCE_DIR}
    -DBESA_GENHTML=${BESA_GENHTML} -P
    ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/gcc.impl.cmake)

  add_custom_target(besa.coverage.${GROUP_NAME}.files DEPENDS ${GROUP_NAME}.info
    WORKING_DIRECTORY ${BESA_COVERAGE_${GROUP_NAME}_OUTDIR})

endfunction()


function(besa_coverage_register_test_impl GROUP_NAME TEST_NAME TARGET_NAME)
  set_tests_properties(
    ${TEST_NAME} PROPERTIES ENVIRONMENT
    GCOV_PREFIX=${BESA_COVERAGE_${GROUP_NAME}_GCDA_DIR})
endfunction()


