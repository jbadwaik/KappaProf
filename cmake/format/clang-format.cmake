# --------------------------------------------------------------------------------------------------
# SPDX-License-Identifier: Apache-2.0
# SPDX-FileCopyrightText: (C) 2024 Jayesh Badwaik <j.badwaik@fz-juelich.de>
# --------------------------------------------------------------------------------------------------

# clang-format.cmake
# A CMake script to run clang-format on the source code. The script expects the following
# variables to be set on the command line before it is called using the `-P` option:
#  - CLANG_FORMAT: The path to the clang-format executable.
#  - GIT : The path to the git executable.

cmake_policy(SET CMP0057 NEW)

execute_process(
  COMMAND find . -not -path '*.git*' -type f
  OUTPUT_VARIABLE RAW_SOURCE_FILE_STRING
  )

message(STATUS "RAW_SOURCE_FILE_STRING: ${RAW_SOURCE_FILE_STRING}")

string(REPLACE "\n" ";" RAW_SOURCE_FILE_LIST "${RAW_SOURCE_FILE_STRING}")

set(EXTENSION_LIST ".c;.h;.m;.cc;.cp;.cpp;.c++;.cxx;.hh;.hpp;.hxx;.cu;.cuh;.cuhpp;.proto;.protodevel;.json")


foreach(SOURCE_FILE ${RAW_SOURCE_FILE_LIST})
  get_filename_component(EXTENSION ${SOURCE_FILE} LAST_EXT)
  if(EXTENSION IN_LIST EXTENSION_LIST)
    list(APPEND SOURCE_FILE_LIST ${SOURCE_FILE})
  endif()
endforeach()

set(GLOBAL_CLANG_FORMAT_RESULT 0)


foreach(SOURCE_FILE ${SOURCE_FILE_LIST})
  execute_process(
    COMMAND ${CLANG_FORMAT} --dry-run -Werror --style=file ${SOURCE_FILE}
    RESULT_VARIABLE CLANG_FORMAT_RESULT
    )

  if(NOT CLANG_FORMAT_RESULT EQUAL 0)
    set(GLOBAL_CLANG_FORMAT_RESULT 1)
    list(APPEND CLANG_FORMAT_ERROR_LIST ${SOURCE_FILE})
  endif()
endforeach()

if(GLOBAL_CLANG_FORMAT_RESULT EQUAL 1)
  string(REPLACE ";" "\n\t" CLANG_FORMAT_ERROR_LIST "${CLANG_FORMAT_ERROR_LIST}")
  message(FATAL_ERROR "clang-format failed on the following files:\n${CLANG_FORMAT_ERROR_LIST}")
endif()
