# --------------------------------------------------------------------------------------------------
# SPDX-License-Identifier: Apache-2.0
# Copyright (C) 2024 Jayesh Badwaik <j.badwaik@fz-juelich.de>
# --------------------------------------------------------------------------------------------------
include_guard(GLOBAL)

function(besa_surrogate_generate_source REL_HDR_FILE DESTINATION_DIR)
  get_filename_component(EXTENSION ${REL_HDR_FILE} LAST_EXT)
  if(${EXTENSION} STREQUAL ".h")
    string(REPLACE ".h" ".c" REL_SRC_FILE ${REL_HDR_FILE})
  elseif(${EXTENSION} STREQUAL ".hpp")
    string(REPLACE ".hpp" ".cpp" REL_SRC_FILE ${REL_HDR_FILE})
  elseif(${EXTENSION} STREQUAL ".cuh")
    string(REPLACE ".cuh" ".cu" REL_SRC_FILE ${REL_HDR_FILE})
  elseif(${EXTENSION} STREQUAL ".cuhpp")
    string(REPLACE ".cuhpp" ".cu" REL_SRC_FILE ${REL_HDR_FILE})
  endif()

  set(SRC_FILE "${DESTINATION_DIR}/${REL_SRC_FILE}")
  set(SRC_FILE ${SRC_FILE} PARENT_SCOPE)
  get_filename_component(BASEDIR ${SRC_FILE} DIRECTORY)
  file(MAKE_DIRECTORY ${BASEDIR})
  file(WRITE ${SRC_FILE} "#include <${REL_HDR_FILE}>\n")
endfunction()

function(besa_surrogate_check TARGET_NAME LABEL_NAME PASS_FAIL)

  cmake_language(
    EVAL CODE
    "cmake_language(DEFER CALL besa_surrogate_check_impl
    [[${TARGET_NAME}]] [[${LABEL_NAME}]] [[${PASS_FAIL}]])"
    )

endfunction()

function(besa_surrogate_check_impl TARGET_NAME LABEL_NAME PASS_FAIL)
  set(DESTINATION_DIR ${PROJECT_BINARY_DIR}/surrogate/${TARGET_NAME}/lib)
  file(MAKE_DIRECTORY ${DESTINATION_DIR})
  get_target_property(DIR_LIST ${TARGET_NAME} INCLUDE_DIRECTORIES)

  set(SURROGATE_TARGET "surrogate.${TARGET_NAME}.t")
  add_library(${SURROGATE_TARGET} EXCLUDE_FROM_ALL)
  target_link_libraries(${SURROGATE_TARGET} PUBLIC ${TARGET_NAME})

  foreach(INCDIR_RAW IN LISTS DIR_LIST)
    if(INCDIR_RAW MATCHES "^\\$<BUILD_INTERFACE:")
      string(REGEX REPLACE "^\\$<BUILD_INTERFACE:" "" INCDIR ${INCDIR_RAW})
      string(REGEX REPLACE ">$" "" INCDIR ${INCDIR})

      target_include_directories(${SURROGATE_TARGET} PUBLIC ${INCDIR})
      file(GLOB_RECURSE REL_HDR_LIST LIST_DIRECTORIES false RELATIVE ${INCDIR}
        CONFIGURE_DEPENDS ${INCDIR}/*)
      foreach(REL_HDR_FILE ${REL_HDR_LIST})
        besa_surrogate_generate_source(${REL_HDR_FILE} ${DESTINATION_DIR})
        target_sources(${SURROGATE_TARGET} PRIVATE ${SRC_FILE})
      endforeach()
    endif()
  endforeach()

  add_test(
    NAME ${SURROGATE_TARGET}
    COMMAND ${CMAKE_COMMAND} --build ${PROJECT_BINARY_DIR} --target
    ${SURROGATE_TARGET} --config $<CONFIGURATION> --verbose
    WORKING_DIRECTORY ${PROJECT_BINARY_DIR})

  if (${PASS_FAIL} STREQUAL "PASS")
    set_tests_properties(${SURROGATE_TARGET} PROPERTIES WILL_FAIL FALSE)
  elseif (${PASS_FAIL} STREQUAL "FAIL")
    set_tests_properties(${SURROGATE_TARGET} PROPERTIES WILL_FAIL TRUE)
  endif()

endfunction()
