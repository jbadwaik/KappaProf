# --------------------------------------------------------------------------------------------------
# SPDX-License-Identifier: Apache-2.0
# Copyright (C) 2024 Jayesh Badwaik <j.badwaik@fz-juelich.de>
# --------------------------------------------------------------------------------------------------

include_guard(GLOBAL)

function(besa_configure_doxygen DOCUMENTATION_TARGET DOXYGEN_OUTPUT_DIRECTORY
    DOXYFILE_IN)
  find_package(Doxygen REQUIRED dot)

  message(DEBUG "Checking besa::doxygen")
  file(MAKE_DIRECTORY ${DOXYGEN_OUTPUT_DIRECTORY})
  set(DOXYFILE ${DOXYGEN_OUTPUT_DIRECTORY}/Doxyfile)
  configure_file(${DOXYFILE_IN} ${DOXYFILE} @ONLY)

  add_custom_target(
    besa.doxygen
    COMMAND Doxygen::doxygen ${DOXYFILE}
    WORKING_DIRECTORY ${DOXYGEN_OUTPUT_DIRECTORY}
    COMMENT "besa::doxygen: Generating API Documentation"
    VERBATIM)

  add_dependencies(${DOCUMENTATION_TARGET} besa.doxygen)
  message(DEBUG "Checking besa::doxygen - Success")
endfunction()

