# --------------------------------------------------------------------------------------------------
# SPDX-License-Identifier: Apache-2.0
# SPDX-FileCopyrightText: (C) 2024 Jayesh Badwaik <j.badwaik@fz-juelich.de>
# --------------------------------------------------------------------------------------------------
include_guard(GLOBAL)

function(besa_mode_check_validity MODE_NAME)
  set(MODE_VALUE ${${MODE_NAME}})

  if(NOT "${MODE_VALUE}" IN_LIST ${MODE_NAME}_ARRAY)
    message(
      FATAL_ERROR
      "
      Invalid ${MODE_NAME} Mode ${${MODE_NAME}}.
      Valid values are: ${${MODE_NAME}_ARRAY}
      "
    )
  endif()
endfunction()

function(besa_mode_help)
  message("Incorrect Usage of besa_mode. Correct Usage is:")
  message(
    FATAL_ERROR
    "
    besa_mode(
      <NAME>
      VALUES <ARRAY_OF_VALUES>
      DESCRIPTION <DESCRIPTION>
    )
    "
  )
endfunction()

function(
    besa_mode
    MODE_NAME
    VALUES_NAME MODE_ARRAY
    DESCRIPTION_NAME DESCRIPTION_VALUE
  )

  if(NOT (${VALUES_NAME} STREQUAL "VALUES"))
    besa_mode_help()
  endif()

  if(NOT (${DESCRIPTION_NAME} STREQUAL "DESCRIPTION"))
    besa_mode_help()
  endif()

  set(${MODE_NAME} "${${MODE_NAME}}"
    CACHE STRING "${DESCRIPTION_VALUE}"
  )

  set_property(CACHE ${MODE_NAME} PROPERTY STRINGS ${MODE_ARRAY})

  set(${MODE_NAME}_ARRAY ${MODE_ARRAY})
  set(${MODE_NAME}_ARRAY ${${MODE_NAME}_ARRAY} PARENT_SCOPE)

  besa_mode_check_validity(${MODE_NAME})

  set(${MODE_NAME} "${${MODE_NAME}}" PARENT_SCOPE)
endfunction()
