# --------------------------------------------------------------------------------------------------
# SPDX-License-Identifier: Apache-2.0
# Copyright (C) 2024 Jayesh Badwaik <j.badwaik@fz-juelich.de>
# --------------------------------------------------------------------------------------------------
include_guard(GLOBAL)


function(besa_add_clang_format TESTNAME)

  find_program(BESA_CLANG_FORMAT clang-format REQUIRED NO_DEFAULT_PATH
    PATHS ${BESA_BINARY_PATH_ARRAY} DOC "clang-format binary")

  add_test(NAME
    ${TESTNAME}
    COMMAND
    ${CMAKE_COMMAND}
    -DCLANG_FORMAT=${BESA_CLANG_FORMAT}
    -P ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/format/clang-format.cmake
    WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
    )

endfunction()


function(besa_add_git_clang_format TESTNAME)

  find_program(BESA_GIT_CLANG_FORMAT git-clang-format REQUIRED NO_DEFAULT_PATH
    PATHS ${BESA_BINARY_PATH_ARRAY} DOC "git-clang-format binary")

  find_program(BESA_GIT git REQUIRED NO_DEFAULT_PATH
    PATHS ${BESA_BINARY_PATH_ARRAY} DOC "git binary")

  add_test(NAME
    ${TESTNAME}
    COMMAND ${CMAKE_COMMAND}
    -DGIT_CLANG_FORMAT=${BESA_GIT_CLANG_FORMAT}
    -DGIT=${BESA_GIT}
    -P ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/format/git-clang-format.cmake
    WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
    )

endfunction()


