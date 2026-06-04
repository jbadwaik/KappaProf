# --------------------------------------------------------------------------------------------------
# SPDX-License-Identifier: Apache-2.0
# Copyright (C) 2024 Jayesh Badwaik <j.badwaik@fz-juelich.de>
# --------------------------------------------------------------------------------------------------
include_guard(GLOBAL)

add_library(besa::ubsan INTERFACE IMPORTED)

if(CMAKE_C_COMPILER_ID STREQUAL "Clang")
  target_compile_options(besa::ubsan INTERFACE
    $<$<COMPILE_LANGUAGE:C>:-fsanitize=undefined>
    $<$<COMPILE_LANGUAGE:C>:-fno-sanitize-recover=undefined>
    $<$<COMPILE_LANGUAGE:C>:-fno-omit-frame-pointer>
    $<$<COMPILE_LANGUAGE:C>:-fno-optimize-sibling-calls>
    )

elseif(CMAKE_C_COMPILER_ID STREQUAL "GNU")
  target_compile_options(besa::ubsan INTERFACE
    $<$<COMPILE_LANGUAGE:C>:-fsanitize=undefined>
    $<$<COMPILE_LANGUAGE:C>:-fno-sanitize-recover=undefined>
    $<$<COMPILE_LANGUAGE:C>:-fno-omit-frame-pointer>
    $<$<COMPILE_LANGUAGE:C>:-fno-optimize-sibling-calls>
    )

else()
  message(FATAL_ERROR "besa/ubsan doesn't yet support the C compiler ${CMAKE_C_COMPILER_ID}")
endif()

if(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
  target_compile_options(besa::ubsan INTERFACE
    $<$<COMPILE_LANGUAGE:CXX>:-fsanitize=undefined>
    $<$<COMPILE_LANGUAGE:CXX>:-fno-sanitize-recover=undefined>
    $<$<COMPILE_LANGUAGE:CXX>:-fno-omit-frame-pointer>
    $<$<COMPILE_LANGUAGE:CXX>:-fno-optimize-sibling-calls>
    )

elseif(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
  target_compile_options(besa::ubsan INTERFACE
    $<$<COMPILE_LANGUAGE:CXX>:-fsanitize=undefined>
    $<$<COMPILE_LANGUAGE:CXX>:-fno-sanitize-recover=undefined>
    $<$<COMPILE_LANGUAGE:CXX>:-fno-omit-frame-pointer>
    $<$<COMPILE_LANGUAGE:CXX>:-fno-optimize-sibling-calls>
    )

else()
  message(FATAL_ERROR "besa/ubsan doesn't yet support the CXX compiler ${CMAKE_C_COMPILER_ID}")
endif()

if((CMAKE_C_COMPILER_ID STREQUAL "Clang" OR CMAKE_C_COMPILER_ID STREQUAL "GNU") AND
  (CMAKE_CXX_COMPILER_ID STREQUAL "Clang" OR CMAKE_CXX_COMPILER_ID STREQUAL "GNU"))

  target_link_options(besa::ubsan INTERFACE
    -fsanitize=undefined
    -fno-sanitize-recover=undefined
    -fno-omit-frame-pointer
    -fno-optimize-sibling-calls
    )

else()
  message(FATAL_ERROR "besa/ubsan doesn't yet support the following combination:"
    "C compiler:    ${CMAKE_C_COMPILER_ID}"
    "CXX Compiler:  ${CMAKE_CXX_COMPILER_ID}")
endif()

