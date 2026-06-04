# --------------------------------------------------------------------------------------------------
# SPDX-License-Identifier: Apache-2.0
# Copyright (C) 2024 Jayesh Badwaik <j.badwaik@fz-juelich.de>
# --------------------------------------------------------------------------------------------------
include_guard(GLOBAL)

function(besa_target_source_directory TARGETNAME LINK_TYPE DIR_NAME)
  file(GLOB_RECURSE SOURCE_FILE_LIST LIST_DIRECTORIES false
    RELATIVE ${CMAKE_CURRENT_LIST_DIR} CONFIGURE_DEPENDS ${DIR_NAME}/*)

  foreach(SRC_FILE ${SOURCE_FILE_LIST})
    target_sources(${TARGETNAME} ${LINK_TYPE} ${SRC_FILE})
  endforeach()
endfunction()

function(besa_target_header_directory TARGETNAME LINK_TYPE DIR_NAME)
  file(GLOB_RECURSE HEADER_FILE_LIST LIST_DIRECTORIES false
    RELATIVE ${CMAKE_CURRENT_LIST_DIR} CONFIGURE_DEPENDS ${DIR_NAME}/*)

  file(REAL_PATH ${DIR_NAME} ABS_DIR_NAME BASE_DIRECTORY ${CMAKE_CURRENT_LIST_DIR})

  target_sources(
    ${TARGETNAME} ${LINK_TYPE} FILE_SET HEADERS BASE_DIRS ${ABS_DIR_NAME} FILES ${HEADER_FILE_LIST})
endfunction()


