# --------------------------------------------------------------------------------------------------
# SPDX-License-Identifier: Apache-2.0
# SPDX-FileCopyrightText: (C) 2024 Jayesh Badwaik <j.badwaik@fz-juelich.de>
# --------------------------------------------------------------------------------------------------
include_guard(GLOBAL)

function(besa_feature_internal_feature_to_variable FEATURE_NAME FEATURE OUTPUT_VARIABLE)
  string(TOUPPER "${FEATURE}" FEATURE_UPPER)
  string(REPLACE "-" "_" FEATURE_UPPER "${FEATURE_UPPER}")
  set(${OUTPUT_VARIABLE} "${FEATURE_NAME}_${FEATURE_UPPER}" PARENT_SCOPE)
endfunction()

function(besa_feature_internal_check_validity FEATURE_NAME)
  set(FEATURE_VALUE ${${FEATURE_NAME}})

  foreach(FEATURE ${FEATURE_VALUE})
    if(FEATURE STREQUAL "none")
      continue()
    endif()

    if(FEATURE STREQUAL "all")
      continue()
    endif()

    if(FEATURE MATCHES "^~(.+)$")
      set(FEATURE "${CMAKE_MATCH_1}")
    endif()

    if(NOT "${FEATURE}" IN_LIST ${FEATURE_NAME}_ARRAY)
      message(
        FATAL_ERROR
        "
        Invalid ${FEATURE_NAME} Feature ${FEATURE}.
        Valid values are: none,${${FEATURE_NAME}_ARRAY},all
        "
      )
    endif()
  endforeach()
endfunction()

function(besa_feature_internal_normalize FEATURE_NAME FEATURE_ARRAY)
  set(INCLUDED_FEATURES "")
  set(EXCLUDED_FEATURES "")

  foreach(FEATURE ${${FEATURE_NAME}})
    if(FEATURE MATCHES "^~(.+)$")
      list(APPEND EXCLUDED_FEATURES "${CMAKE_MATCH_1}")
    else()
      list(APPEND INCLUDED_FEATURES "${FEATURE}")
    endif()
  endforeach()

  if("none" IN_LIST INCLUDED_FEATURES)
    list(LENGTH INCLUDED_FEATURES FEATURE_LENGTH)
    if(NOT (${FEATURE_LENGTH} EQUAL 1))
      message(
        FATAL_ERROR
        "
        none is mutually exclusive with other ${FEATURE_NAME} features.
        "
      )
    endif()

    set(INCLUDED_FEATURES "")
  elseif("all" IN_LIST INCLUDED_FEATURES)
    list(LENGTH INCLUDED_FEATURES FEATURE_LENGTH)
    if(NOT (${FEATURE_LENGTH} EQUAL 1))
      message(
        FATAL_ERROR
        "
        all is mutually exclusive with explicit included ${FEATURE_NAME} features.
        Use all with optional exclusions, for example: all;~foo
        "
      )
    endif()

    set(INCLUDED_FEATURES ${FEATURE_ARRAY})
  endif()

  foreach(FEATURE ${EXCLUDED_FEATURES})
    list(REMOVE_ITEM INCLUDED_FEATURES "${FEATURE}")
  endforeach()

  if(INCLUDED_FEATURES)
    list(REMOVE_DUPLICATES INCLUDED_FEATURES)
  endif()

  set(${FEATURE_NAME} ${INCLUDED_FEATURES} PARENT_SCOPE)
endfunction()

function(besa_feature_register REGISTRY NAME DESCRIPTION)
  string(TOUPPER "${NAME}" NAME_UPPER)
  string(REPLACE "-" "_" NAME_UPPER "${NAME_UPPER}")

  option(PROJECT_FEATURE_${NAME_UPPER} "${DESCRIPTION}")

  list(APPEND ${REGISTRY} "${NAME}")
  set(${REGISTRY} "${${REGISTRY}}"
    CACHE INTERNAL "Registered project features" FORCE)
endfunction()

function(besa_feature_help)
  message("Incorrect Usage of besa_feature. Correct Usage is:")
  message(
    FATAL_ERROR
    "
    besa_feature(
      <NAME>
      VALUES <ARRAY_OF_SUPPORTED_VALUES>
      DESCRIPTION <DESCRIPTION>
    )
    "
  )
endfunction()

function(
    besa_feature_process
    FEATURE_NAME
    VALUES_NAME FEATURE_ARRAY
    DESCRIPTION_NAME DESCRIPTION_STRING
  )

  if(NOT (${VALUES_NAME} STREQUAL "VALUES"))
    besa_feature_help()
  endif()

  if(NOT (${DESCRIPTION_NAME} STREQUAL "DESCRIPTION"))
    besa_feature_help()
  endif()

  set(${FEATURE_NAME}_ARRAY ${FEATURE_ARRAY})
  set(${FEATURE_NAME}_ARRAY ${${FEATURE_NAME}_ARRAY} PARENT_SCOPE)

  besa_feature_internal_check_validity(${FEATURE_NAME})

  besa_feature_internal_normalize(${FEATURE_NAME} "${FEATURE_ARRAY}")
  set(${FEATURE_NAME} ${${FEATURE_NAME}} PARENT_SCOPE)

  foreach(FEATURE ${FEATURE_ARRAY})
    besa_feature_internal_feature_to_variable(
      ${FEATURE_NAME}
      ${FEATURE}
      FEATURE_VARIABLE
    )

    set(${FEATURE_VARIABLE} FALSE PARENT_SCOPE)
  endforeach()

  foreach(FEATURE ${${FEATURE_NAME}})
    besa_feature_internal_feature_to_variable(
      ${FEATURE_NAME}
      ${FEATURE}
      FEATURE_VARIABLE
    )

    set(${FEATURE_VARIABLE} TRUE PARENT_SCOPE)
  endforeach()

endfunction()

function(besa_feature_to_cpp_definition CPP_PREFIX FEATURE OUTPUT_VARIABLE)
  string(TOUPPER "${FEATURE}" FEATURE_UPPER)
  string(REPLACE "-" "_" FEATURE_UPPER "${FEATURE_UPPER}")
  set(${OUTPUT_VARIABLE} "${CPP_PREFIX}_${FEATURE_UPPER}" PARENT_SCOPE)
endfunction()

function(besa_feature_apply_to_target TARGET_NAME FEATURE_NAME VISIBILITY CPP_PREFIX)
  if(NOT TARGET ${TARGET_NAME})
    message(FATAL_ERROR "Target ${TARGET_NAME} does not exist.")
  endif()

  foreach(FEATURE ${${FEATURE_NAME}_ARRAY})
    besa_feature_internal_feature_to_variable(${FEATURE_NAME} ${FEATURE} CMAKE_FEATURE_VARIABLE)
    besa_feature_to_cpp_definition(${CPP_PREFIX} ${FEATURE} CPP_FEATURE_DEFINITION)
    if(${CMAKE_FEATURE_VARIABLE})
      target_compile_definitions(${TARGET_NAME} ${VISIBILITY} "${CPP_FEATURE_DEFINITION}")
    endif()
  endforeach()
endfunction()
