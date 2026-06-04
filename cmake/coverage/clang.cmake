# --------------------------------------------------------------------------------------------------
# SPDX-License-Identifier: Apache-2.0
# Copyright (C) 2024 Jayesh Badwaik <j.badwaik@fz-juelich.de>
# --------------------------------------------------------------------------------------------------
include_guard(GLOBAL)

if(NOT CMAKE_CXX_COMPILER_ID STREQUAL CMAKE_C_COMPILER_ID)
  message(FATAL_ERROR "C and C++ Compilers should be the same for coverage to work.")
endif()

target_compile_options(besa::coverage INTERFACE
  $<$<COMPILE_LANGUAGE:C>:-fprofile-instr-generate>
  $<$<COMPILE_LANGUAGE:C>:-fcoverage-mapping>
  $<$<COMPILE_LANGUAGE:CXX>:-fprofile-instr-generate>
  $<$<COMPILE_LANGUAGE:CXX>:-fcoverage-mapping>
  )

target_link_options(besa::coverage INTERFACE
  -fprofile-instr-generate
  -fcoverage-mapping
  )

find_program(BESA_LLVM_PROFDATA llvm-profdata REQUIRED NO_DEFAULT_PATH
  PATHS ${BESA_BINARY_PATH_ARRAY} DOC "llvm-profdata executable"
  )

find_program(BESA_LLVM_COV llvm-cov REQUIRED NO_DEFAULT_PATH
  PATHS ${BESA_BINARY_PATH_ARRAY} DOC "llvm-cov executable"
  )

function(besa_coverage_process_group_impl GROUP_NAME)
  set(PROFILE_FILE_ARRAY)
  foreach(TEST ${BESA_COVERAGE_${GROUP_NAME}_TEST_ARRAY})
    list(APPEND PROFILE_FILE_ARRAY
      "${BESA_COVERAGE_${GROUP_NAME}_OUTDIR}/prof/${TEST}.prof")
  endforeach()

  set(TARGET_PATH_ARRAY)
  foreach(TARGET ${BESA_COVERAGE_${GROUP_NAME}_TARGET_ARRAY})

    # Command Line Friendly Generation "-object <target_file>"
    list(APPEND TARGET_PATH_ARRAY "-object")
    list(APPEND TARGET_PATH_ARRAY "$<TARGET_FILE:${TARGET}>")

  endforeach()

  add_custom_command(
    OUTPUT ${GROUP_NAME}.profdata
    WORKING_DIRECTORY ${BESA_COVERAGE_${GROUP_NAME}_OUTDIR}
    COMMAND ${BESA_LLVM_PROFDATA} merge -sparse ${PROFILE_FILE_ARRAY} -o
    ${GROUP_NAME}.profdata
    DEPENDS ${TARGET_NAME})

  add_custom_command(
    OUTPUT ${GROUP_NAME}.dat
    WORKING_DIRECTORY ${BESA_COVERAGE_${GROUP_NAME}_OUTDIR}
    COMMAND
    ${BESA_LLVM_COV} show ${TARGET_PATH_ARRAY}
    -instr-profile=${GROUP_NAME}.profdata -Xdemangler=c++filt
    -show-instantiation-summary > ${GROUP_NAME}.dat
    DEPENDS ${GROUP_NAME}.profdata)

  add_custom_command(
    OUTPUT ${GROUP_NAME}.json
    WORKING_DIRECTORY ${BESA_COVERAGE_${GROUP_NAME}_OUTDIR}
    COMMAND
    ${BESA_LLVM_COV} export ${TARGET_PATH_ARRAY}
    -instr-profile=${GROUP_NAME}.profdata -Xdemangler=c++filt >
    ${GROUP_NAME}.json
    DEPENDS ${GROUP_NAME}.profdata)

  add_custom_command(
    OUTPUT ${GROUP_NAME}.html
    WORKING_DIRECTORY ${BESA_COVERAGE_${GROUP_NAME}_OUTDIR}
    COMMAND
    ${BESA_LLVM_COV} show ${TARGET_PATH_ARRAY}
    -instr-profile=${GROUP_NAME}.profdata -Xdemangler=c++filt --format=html
    -region-coverage-lt=100 > ${GROUP_NAME}.html
    DEPENDS ${GROUP_NAME}.profdata)

  add_custom_target(
    besa.coverage.${GROUP_NAME}.files
    DEPENDS ${GROUP_NAME}.dat ${GROUP_NAME}.html ${GROUP_NAME}.json
    WORKING_DIRECTORY ${BESA_COVERAGE_${GROUP_NAME}_OUTDIR})

endfunction()

function(besa_coverage_register_test_impl GROUP_NAME TEST_NAME TARGET_NAME)
  set_tests_properties(
    ${TEST_NAME}
    PROPERTIES
    ENVIRONMENT
    LLVM_PROFILE_FILE=${BESA_COVERAGE_${GROUP_NAME}_OUTDIR}/prof/${TEST_NAME}.prof
    )

endfunction()
