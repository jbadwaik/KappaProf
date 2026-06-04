# --------------------------------------------------------------------------------------------------
# SPDX-License-Identifier: Apache-2.0
# Copyright (C) 2024 Jayesh Badwaik <j.badwaik@fz-juelich.de>
# --------------------------------------------------------------------------------------------------
include_guard(GLOBAL)

find_program(
  BESA_VERSION_GIT git NO_DEFAULT_PATH PATHS ${BESA_BINARY_PATH_ARRAY}
  DOC "git executable for besa version module")

set(BESA_VERSION_GENCODE_DIR ${PROJECT_BINARY_DIR}/coverage
  CACHE PATH "Path to Store Output of Coverage Data")

function(besa_compute_version)
  set(PKGBUILDER_INFO "${PKGBUILDER_ID}-${PKGBUILDER_REVISION}")
  set(RELEASE_INFO  "${RELEASE_TYPE}.${RELEASE_REVISION}")

  if(${RELEASE_TYPE} STREQUAL "release")
    set(PROJECT_SEMVER            "${PROJECT_VERSION}")
    set(PROJECT_BUILD_VERSION     "${PROJECT_VERSION}-${PKGBUILDER_INFO}")

  elseif(${RELEASE_TYPE} STREQUAL "dev")
    besa_version_tree_hash(GIT_TREE_HASH)
    besa_version_branch(GIT_BRANCH)

    set(GIT_VERSION "${GIT_BRANCH}.${GIT_TREE_HASH}")

    set(PROJECT_SEMVER            "dev.${GIT_VERSION}")
    set(PROJECT_BUILD_VERSION     "dev.${GIT_VERSION}-${PKGBUILDER_INFO}")

  else()
    set(PROJECT_SEMVER            "${PROJECT_VERSION}-${RELEASE_INFO}")
    set(PROJECT_BUILD_VERSION     "${PROJECT_VERSION}-${RELEASE_INFO}-${PKGBUILDER_INFO}")
  endif()

  set(PROJECT_GIT_TREE_HASH "${GIT_TREE_HASH}" PARENT_SCOPE)
  set(PROJECT_GIT_BRANCH "${GIT_BRANCH}" PARENT_SCOPE)
  set(PROJECT_SEMVER "${PROJECT_SEMVER}" PARENT_SCOPE)
  set(PROJECT_BUILD_VERSION "${PROJECT_BUILD_VERSION}" PARENT_SCOPE)
endfunction()


function(besa_version_tree_hash GIT_TREE_HASH)
  if(${BESA_VERSION_GIT} STREQUAL "BESA_VERSION_GIT-NOTFOUND")
    set(${GIT_TREE_HASH} "gitnotfound" PARENT_SCOPE)
  endif()

  execute_process(
    COMMAND ${BESA_VERSION_GIT} rev-parse --is-inside-work-tree
    OUTPUT_VARIABLE IS_INSIDE_GIT_WORKTREE ERROR_VARIABLE GIT_ERROR
    RESULT_VARIABLE GIT_RESULT
    WORKING_DIRECTORY ${PROJECT_SOURCE_DIR})

  if(${GIT_RESULT} STREQUAL "0")
    execute_process(
      COMMAND ${BESA_VERSION_GIT} rev-parse --short --verify HEAD
      OUTPUT_VARIABLE LOCAL_GIT_TREE_HASH ERROR_VARIABLE GIT_ERROR
      WORKING_DIRECTORY ${PROJECT_SOURCE_DIR})

    string(REGEX REPLACE "\n$" "" LOCAL_GIT_TREE_HASH "${LOCAL_GIT_TREE_HASH}")
    set(${GIT_TREE_HASH} "${LOCAL_GIT_TREE_HASH}" PARENT_SCOPE)
  else()
    set(${GIT_TREE_HASH} "reponotgit" PARENT_SCOPE)
  endif()

endfunction()

function(besa_version_branch GIT_BRANCH)
  if(${BESA_VERSION_GIT} STREQUAL "BESA_VERSION_GIT-NOTFOUND")
    set(${GIT_TREE_HASH} "gitnotfound" PARENT_SCOPE)
  endif()

  execute_process(
    COMMAND ${BESA_VERSION_GIT} rev-parse --is-inside-work-tree
    OUTPUT_VARIABLE IS_INSIDE_GIT_WORKTREE ERROR_VARIABLE GIT_ERROR
    RESULT_VARIABLE GIT_RESULT
    WORKING_DIRECTORY ${PROJECT_SOURCE_DIR})

  if(${GIT_RESULT} STREQUAL "0")
    execute_process(
      COMMAND ${BESA_VERSION_GIT} rev-parse --abbrev-ref HEAD
      OUTPUT_VARIABLE LOCAL_GIT_BRANCH ERROR_VARIABLE GIT_ERROR
      WORKING_DIRECTORY ${PROJECT_SOURCE_DIR})

    string(REGEX REPLACE "\n$" "" LOCAL_GIT_BRANCH "${LOCAL_GIT_BRANCH}")
    set(${GIT_BRANCH} "${LOCAL_GIT_BRANCH}" PARENT_SCOPE)
  else()
    set(${GIT_BRANCH} "reponotgit" PARENT_SCOPE)
  endif()

endfunction()

