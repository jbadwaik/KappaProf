# --------------------------------------------------------------------------------------------------
# SPDX-License-Identifier: Apache-2.0
# Copyright (C) 2024 Jayesh Badwaik <j.badwaik@fz-juelich.de>
# --------------------------------------------------------------------------------------------------

# --------------------------------------------------------------------------------------------------
# Warning Deprecated
# --------------------------------------------------------------------------------------------------
add_library(besa::warning.deprecated INTERFACE IMPORTED)

if(CMAKE_C_COMPILER_ID STREQUAL "Clang")
  target_compile_options(besa::warning.deprecated INTERFACE $<$<COMPILE_LANGUAGE:C>:-Wdeprecated>)
elseif(CMAKE_C_COMPILER_ID STREQUAL "GNU")
  target_compile_options(besa::warning.deprecated INTERFACE $<$<COMPILE_LANGUAGE:C>:-Wdeprecated>)
endif()

if(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
  target_compile_options(besa::warning.deprecated INTERFACE $<$<COMPILE_LANGUAGE:CXX>:-Wdeprecated>)
elseif(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
  target_compile_options(besa::warning.deprecated INTERFACE $<$<COMPILE_LANGUAGE:CXX>:-Wdeprecated>)
endif()

# --------------------------------------------------------------------------------------------------
# Warning Error
# --------------------------------------------------------------------------------------------------

add_library(besa::warning.error INTERFACE IMPORTED)

if(CMAKE_C_COMPILER_ID STREQUAL "Clang")
  target_compile_options(besa::warning.error INTERFACE $<$<COMPILE_LANGUAGE:C>:-Werror>)
elseif(CMAKE_C_COMPILER_ID STREQUAL "GNU")
  target_compile_options(besa::warning.error INTERFACE $<$<COMPILE_LANGUAGE:C>:-Werror>)
endif()

if(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
  target_compile_options(besa::warning.error INTERFACE $<$<COMPILE_LANGUAGE:CXX>:-Werror>)
elseif(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
  target_compile_options(besa::warning.error INTERFACE $<$<COMPILE_LANGUAGE:CXX>:-Werror>)
endif()

# --------------------------------------------------------------------------------------------------
# Warning Essential
# --------------------------------------------------------------------------------------------------
add_library(besa::warning.essential INTERFACE IMPORTED)

if(CMAKE_C_COMPILER_ID STREQUAL "Clang")
  target_compile_options(besa::warning.essential INTERFACE
    $<$<COMPILE_LANGUAGE:C>:-Wall>
    $<$<COMPILE_LANGUAGE:C>:-Wextra>
    $<$<COMPILE_LANGUAGE:C>:-Wpedantic>
    )
elseif(CMAKE_C_COMPILER_ID STREQUAL "GNU")
  target_compile_options(besa::warning.essential INTERFACE
    $<$<COMPILE_LANGUAGE:C>:-Wall>
    $<$<COMPILE_LANGUAGE:C>:-Wextra>
    $<$<COMPILE_LANGUAGE:C>:-Wpedantic>
    )
endif()

if(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
  target_compile_options(besa::warning.essential INTERFACE
    $<$<COMPILE_LANGUAGE:CXX>:-Wall>
    $<$<COMPILE_LANGUAGE:CXX>:-Wextra>
    $<$<COMPILE_LANGUAGE:CXX>:-Wpedantic>
    )
elseif(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
  target_compile_options(besa::warning.essential INTERFACE
    $<$<COMPILE_LANGUAGE:CXX>:-Wall>
    $<$<COMPILE_LANGUAGE:CXX>:-Wextra>
    $<$<COMPILE_LANGUAGE:CXX>:-Wpedantic>
    )
endif()


# --------------------------------------------------------------------------------------------------
# Warning Everything
# --------------------------------------------------------------------------------------------------

add_library(besa::warning.everything INTERFACE IMPORTED)

if(CMAKE_C_COMPILER_ID STREQUAL "Clang")
  target_compile_options(besa::warning.everything INTERFACE
    $<$<COMPILE_LANGUAGE:C>:-Weverything>
    $<$<COMPILE_LANGUAGE:C>:-Wno-c++98-compat>
    $<$<COMPILE_LANGUAGE:C>:-Wno-c++20-compat>
    $<$<COMPILE_LANGUAGE:C>:-Wno-c++98-compat-pedantic>
    $<$<COMPILE_LANGUAGE:C>:-Wno-covered-switch-default>
    $<$<COMPILE_LANGUAGE:C>:-Wno-padded>
    $<$<COMPILE_LANGUAGE:C>:-Wno-weak-vtables>
    )
elseif(CMAKE_C_COMPILER_ID STREQUAL "GNU")
  target_compile_options(besa::warning.everything INTERFACE
    $<$<COMPILE_LANGUAGE:C>:-Wall>
    $<$<COMPILE_LANGUAGE:C>:-Wextra>
    $<$<COMPILE_LANGUAGE:C>:-Wpedantic>
    )
endif()

if(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
  target_compile_options(besa::warning.everything INTERFACE
    $<$<COMPILE_LANGUAGE:CXX>:-Weverything>
    $<$<COMPILE_LANGUAGE:CXX>:-Wno-c++98-compat>
    $<$<COMPILE_LANGUAGE:CXX>:-Wno-c++20-compat>
    $<$<COMPILE_LANGUAGE:CXX>:-Wno-c++98-compat-pedantic>
    $<$<COMPILE_LANGUAGE:CXX>:-Wno-covered-switch-default>
    $<$<COMPILE_LANGUAGE:CXX>:-Wno-padded>
    $<$<COMPILE_LANGUAGE:CXX>:-Wno-weak-vtables>
    )
elseif(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
  target_compile_options(besa::warning.everything INTERFACE
    $<$<COMPILE_LANGUAGE:CXX>:-Wall>
    $<$<COMPILE_LANGUAGE:CXX>:-Wextra>
    $<$<COMPILE_LANGUAGE:CXX>:-Wpedantic>
    )
endif()


