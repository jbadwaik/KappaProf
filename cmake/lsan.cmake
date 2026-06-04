# --------------------------------------------------------------------------------------------------
# SPDX-License-Identifier: Apache-2.0
# Copyright (C) 2024 Jayesh Badwaik <j.badwaik@fz-juelich.de>
# --------------------------------------------------------------------------------------------------
include_guard(GLOBAL)

add_library(besa::lsan INTERFACE IMPORTED)

if(CMAKE_C_COMPILER_ID STREQUAL "Clang")
  target_compile_options(besa::lsan INTERFACE $<$<COMPILE_LANGUAGE:C>:-fsanitize=leak>)

elseif(CMAKE_C_COMPILER_ID STREQUAL "GNU")
  target_compile_options(besa::lsan INTERFACE $<$<COMPILE_LANGUAGE:C>:-fsanitize=leak>)
else()
  message(FATAL_ERROR "besa/lsan doesn't yet support the C compiler ${CMAKE_C_COMPILER_ID}")
endif()

if(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
  target_compile_options(besa::lsan INTERFACE $<$<COMPILE_LANGUAGE:CXX>:-fsanitize=leak>)
elseif(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
  target_compile_options(besa::lsan INTERFACE $<$<COMPILE_LANGUAGE:CXX>:-fsanitize=leak>)
else()
  message(FATAL_ERROR "besa/lsan doesn't yet support the CXX compiler ${CMAKE_C_COMPILER_ID}")
endif()

if((CMAKE_C_COMPILER_ID STREQUAL "Clang" OR CMAKE_C_COMPILER_ID STREQUAL "GNU") AND
  (CMAKE_CXX_COMPILER_ID STREQUAL "Clang" OR CMAKE_CXX_COMPILER_ID STREQUAL "GNU"))

  target_link_options(besa::lsan INTERFACE -fsanitize=leak)

else()
  message(FATAL_ERROR "besa/lsan doesn't yet support the following combination:"
    "C compiler:    ${CMAKE_C_COMPILER_ID}"
    "CXX Compiler:  ${CMAKE_CXX_COMPILER_ID}")
endif()

