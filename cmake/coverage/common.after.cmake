# --------------------------------------------------------------------------------------------------
# SPDX-License-Identifier: Apache-2.0
# Copyright (C) 2024 Jayesh Badwaik <j.badwaik@fz-juelich.de>
# --------------------------------------------------------------------------------------------------

function(besa_coverage_register_test GROUP_NAME TEST_NAME TARGET_NAME)
  if(NOT TARGET besa.coverage.${GROUP_NAME})
    besa_coverage_initialize_group(${GROUP_NAME})
  endif()

  besa_coverage_register_test_noinit(${GROUP_NAME} ${TEST_NAME} ${TARGET_NAME})
endfunction()

function(besa_coverage_register_test_noinit GROUP_NAME TEST_NAME TARGET_NAME)
  if(NOT TARGET besa.coverage.${GROUP_NAME})
    message(FATAL_ERROR "Unknown Test Coverage Group: ${GROUP_NAME}")
  endif()

  besa_coverage_register_test_impl(${GROUP_NAME} ${TEST_NAME} ${TARGET_NAME})

  list(APPEND BESA_COVERAGE_${GROUP_NAME}_TEST_ARRAY "${TEST_NAME}")

  set(BESA_COVERAGE_${GROUP_NAME}_TEST_ARRAY
    ${BESA_COVERAGE_${GROUP_NAME}_TEST_ARRAY}
    CACHE INTERNAL "${GROUP_NAME} Test Array")

  list(APPEND BESA_COVERAGE_${GROUP_NAME}_TARGET_ARRAY "${TARGET_NAME}")

  set(BESA_COVERAGE_${GROUP_NAME}_TARGET_ARRAY
    ${BESA_COVERAGE_${GROUP_NAME}_TARGET_ARRAY}
    CACHE INTERNAL "${GROUP_NAME} Test Array")

endfunction()



function(besa_coverage_initialize_group GROUP_NAME)
  add_custom_target(besa.coverage.${GROUP_NAME})
  add_dependencies(besa.coverage besa.coverage.${GROUP_NAME})

  add_test(
    NAME besa.coverage.${GROUP_NAME}.t
    COMMAND ${CMAKE_COMMAND} --build . --target besa.coverage.${GROUP_NAME} --config $<CONFIG>
    WORKING_DIRECTORY ${PROJECT_BINARY_DIR})

  list(APPEND BESA_COVERAGE_GROUP_ARRAY ${GROUP_NAME})

  set(BESA_COVERAGE_GROUP_ARRAY ${BESA_COVERAGE_GROUP_ARRAY}
    CACHE INTERNAL "Coverage Group Array")

  list(APPEND BESA_COVERAGE_GROUP_TEST_ARRAY besa.coverage.${GROUP_NAME}.t)

  set(BESA_COVERAGE_GROUP_TEST_ARRAY ${BESA_COVERAGE_GROUP_TEST_ARRAY}
    CACHE INTERNAL "Coverage Group Test Array")

  set(BESA_COVERAGE_${GROUP_NAME}_OUTDIR_LOCAL
    ${BESA_COVERAGE_OUTDIR}/${GROUP_NAME})

  set(BESA_COVERAGE_${GROUP_NAME}_OUTDIR
    ${BESA_COVERAGE_${GROUP_NAME}_OUTDIR_LOCAL}
    CACHE INTERNAL "${GROUP_NAME} Output Directory")

  set(BESA_COVERAGE_${GROUP_NAME}_GCDA_DIR
    ${BESA_COVERAGE_${GROUP_NAME}_OUTDIR}/gcda/
    CACHE INTERNAL "${GROUP_NAME} GCDA Output Directory")

  set(BESA_COVERAGE_${GROUP_NAME}_TEST_ARRAY CACHE INTERNAL
    "${GROUP_NAME} Test Array")

  set(BESA_COVERAGE_${GROUP_NAME}_TARGET_ARRAY
    CACHE INTERNAL "${GROUP_NAME} Target Array")

  file(MAKE_DIRECTORY ${BESA_COVERAGE_${GROUP_NAME}_OUTDIR_LOCAL}/prof)

endfunction()

function(besa_coverage_process_group GROUP_NAME)
  if(NOT TARGET besa.coverage.${GROUP_NAME})
    message(FATAL_ERROR "Unknown Test Coverage Group: ${GROUP_NAME}")
  endif()

  set_tests_properties(
    besa.coverage.${GROUP_NAME}.t PROPERTIES DEPENDS "${BESA_COVERAGE_${GROUP_NAME}_TEST_ARRAY}")

  message(STATUS "${BESA_COVERAGE_${GROUP_NAME}_TEST_ARRAY}")

  add_dependencies(besa.coverage.${GROUP_NAME}
    besa.coverage.${GROUP_NAME}.files)

  besa_coverage_process_group_impl(${GROUP_NAME})
endfunction()

function(besa_coverage_process)
  foreach(GROUP_NAME ${BESA_COVERAGE_GROUP_ARRAY})
    besa_coverage_process_group(${GROUP_NAME})
  endforeach()

  set_tests_properties(besa.coverage.t PROPERTIES DEPENDS "${BESA_COVERAGE_GROUP_TEST_ARRAY}")
endfunction()
