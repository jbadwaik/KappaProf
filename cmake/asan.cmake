# --------------------------------------------------------------------------------------------------
# SPDX-License-Identifier: Apache-2.0
# Copyright (C) 2024 Jayesh Badwaik <j.badwaik@fz-juelich.de>
# --------------------------------------------------------------------------------------------------
include_guard(GLOBAL)

add_library(besa::asan INTERFACE IMPORTED)

if(CMAKE_C_COMPILER_ID STREQUAL "Clang")
  target_compile_options(besa::asan INTERFACE
    $<$<COMPILE_LANGUAGE:C>:-fsanitize=address>
    $<$<COMPILE_LANGUAGE:C>:-fno-sanitize-recover=address>
    $<$<COMPILE_LANGUAGE:C>:-fno-omit-frame-pointer>
    $<$<COMPILE_LANGUAGE:C>:-fno-optimize-sibling-calls>
    $<$<COMPILE_LANGUAGE:C>:-fsanitize-address-use-after-scope>)

elseif(CMAKE_C_COMPILER_ID STREQUAL "GNU")
  target_compile_options(besa::asan INTERFACE
    $<$<COMPILE_LANGUAGE:C>:-fsanitize=address>
    $<$<COMPILE_LANGUAGE:C>:-fno-sanitize-recover=address>
    $<$<COMPILE_LANGUAGE:C>:-fno-omit-frame-pointer>
    $<$<COMPILE_LANGUAGE:C>:-fno-optimize-sibling-calls>
    $<$<COMPILE_LANGUAGE:C>:-fsanitize-address-use-after-scope>)
else()
  message(FATAL_ERROR "besa/asan doesn't yet support the C compiler ${CMAKE_C_COMPILER_ID}")
endif()

if(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
  target_compile_options(besa::asan INTERFACE
    $<$<COMPILE_LANGUAGE:CXX>:-fsanitize=address>
    $<$<COMPILE_LANGUAGE:CXX>:-fno-sanitize-recover=address>
    $<$<COMPILE_LANGUAGE:CXX>:-fno-omit-frame-pointer>
    $<$<COMPILE_LANGUAGE:CXX>:-fno-optimize-sibling-calls>
    $<$<COMPILE_LANGUAGE:CXX>:-fsanitize-address-use-after-scope>)
elseif(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
  target_compile_options(besa::asan INTERFACE
    $<$<COMPILE_LANGUAGE:CXX>:-fsanitize=address>
    $<$<COMPILE_LANGUAGE:CXX>:-fno-sanitize-recover=address>
    $<$<COMPILE_LANGUAGE:CXX>:-fno-omit-frame-pointer>
    $<$<COMPILE_LANGUAGE:CXX>:-fno-optimize-sibling-calls>
    $<$<COMPILE_LANGUAGE:CXX>:-fsanitize-address-use-after-scope>)
else()
  message(FATAL_ERROR "besa/asan doesn't yet support the CXX compiler ${CMAKE_C_COMPILER_ID}")
endif()

if((CMAKE_C_COMPILER_ID STREQUAL "Clang" OR CMAKE_C_COMPILER_ID STREQUAL "GNU") AND
  (CMAKE_CXX_COMPILER_ID STREQUAL "Clang" OR CMAKE_CXX_COMPILER_ID STREQUAL "GNU"))
  target_link_options(besa::asan
    INTERFACE
    -fsanitize=address
    -fno-sanitize-recover=address
    -fno-omit-frame-pointer
    -fno-optimize-sibling-calls
    -fsanitize-address-use-after-scope)
else()
  message(FATAL_ERROR "besa/asan doesn't yet support the following combination:"
    "C compiler:    ${CMAKE_C_COMPILER_ID}"
    "CXX Compiler:  ${CMAKE_CXX_COMPILER_ID}")
endif()

