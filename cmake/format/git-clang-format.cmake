# --------------------------------------------------------------------------------------------------
# SPDX-License-Identifier: Apache-2.0
# SPDX-FileCopyrightText: (C) 2024 Jayesh Badwaik <j.badwaik@fz-juelich.de>
# --------------------------------------------------------------------------------------------------

# git-clang-format.cmake
# A CMake script to run git-clang-format on the current project. The script
# expects the following variables to be set on the command line before it is
# called using the `-P` option:
# - GIT_CLANG_FORMAT : Absolute path to the git-clang-format script
# - GIT : Absolute path to the git executable

message(STATUS "Running git-clang-format on the current project")

execute_process(
  COMMAND ${GIT} diff-index --quiet HEAD --
  RESULT_VARIABLE GIT_DIFF_INDEX_RESULT
  )

if(GIT_DIFF_INDEX_RESULT EQUAL 0)
  set(REPOSITORY_IS_DIRTY FALSE)
else()
  set(REPOSITORY_IS_DIRTY TRUE)
endif()

if(REPOSITORY_IS_DIRTY)
  message(STATUS "Repository is dirty, running git-clang-format on uncommited changes")
  execute_process(
    COMMAND ${GIT_CLANG_FORMAT} --diff HEAD~
    RESULT_VARIABLE GIT_CLANG_FORMAT_RESULT
    )
  if(NOT GIT_CLANG_FORMAT_RESULT EQUAL 0)
    message(FATAL_ERROR "The repository is NOT formatted correctly.")
  else()
    message(STATUS "Repository is formatted correctly.")
  endif()

else()
  message(STATUS "Repository is clean, running git-clang-format on the last commit")

  execute_process(
    COMMAND ${GIT_CLANG_FORMAT} --diff --style=file HEAD HEAD~
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    RESULT_VARIABLE GIT_CLANG_FORMAT_RESULT
    )
  if(NOT GIT_CLANG_FORMAT_RESULT EQUAL 0)
    message(FATAL_ERROR "The repository is NOT formatted correctly.")
  else()
    message(STATUS "Repository is formatted correctly.")
  endif()
endif()


