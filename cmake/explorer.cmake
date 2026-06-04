# --------------------------------------------------------------------------------------------------
# SPDX-License-Identifier: Apache-2.0
# Copyright (C) 2024 Jayesh Badwaik <j.badwaik@fz-juelich.de>
# --------------------------------------------------------------------------------------------------
include_guard(GLOBAL)

function(besa_explorer_test TEST_NAME FILENAME LINK_LIBRARY)
  get_filename_component(EXTENSION ${FILENAME} LAST_EXT)
  if((${EXTENSION} STREQUAL ".cpp") OR (${EXTENSION} STREQUAL ".c"))
    add_library(${TEST_NAME}.o OBJECT ${FILENAME})
    target_link_libraries(${TEST_NAME}.o PRIVATE ${LINK_LIBRARY})

    add_custom_command(
      OUTPUT ${TEST_NAME}.s
      COMMAND objdump -drwC -Mintel $<TARGET_OBJECTS:${TEST_NAME}.o> >
      ${TEST_NAME}.s DEPENDS ${TEST_NAME}.o)
    add_custom_command(
      OUTPUT ${TEST_NAME}.s
      COMMAND objdump -drwC -Mintel $<TARGET_OBJECTS:${TEST_NAME}.o> >
      ${TEST_NAME}.s DEPENDS ${TEST_NAME}.o)
  else()
    message(STATUS "Unrecognized File Extension.")
    message(FATAL_ERROR "Recognized extensions: cpp, c")
  endif()

  add_custom_target(${TEST_NAME} ALL DEPENDS ${TEST_NAME}.s)
endfunction()
