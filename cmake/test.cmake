# --------------------------------------------------------------------------------------------------
# SPDX-License-Identifier: Apache-2.0
# Copyright (C) 2024 Jayesh Badwaik <j.badwaik@fz-juelich.de>
# --------------------------------------------------------------------------------------------------
include_guard(GLOBAL)

# Optional coverage hooks and builder utilities used by the test targets.
include(${CMAKE_CURRENT_LIST_DIR}/coverage.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/builder.cmake)

# ------------------------------------------------------------------------------
# Internal helper: besa_internal_unit_test_name
#
# Computes a CTest/target name for a runtime unit test executable:
#   - removes the file extension from the source filename
#   - prefixes it with PREFIX and a dot: "<PREFIX>.<basename>"
#
# Arguments:
#   FILENAME   : (unused in current implementation; historically intended as input)
#   PREFIX     : prefix namespace for all tests created by the caller
#   TARGETNAME : (output variable name) receives the computed target name
#
# Implementation note:
#   The function currently uses the variable SOURCE rather than FILENAME when stripping
#   extensions. This works because callers set SOURCE in the foreach loop. Keep this
#   behavior in mind if refactoring.
# ------------------------------------------------------------------------------
function(besa_internal_unit_test_name FILENAME PREFIX TARGETNAME)
  # Remove the extension from the source file name
  string(REGEX REPLACE "\\.[^.]*$" "" TARGETNAME ${SOURCE})
  set(TARGETNAME "${PREFIX}.${TARGETNAME}")
  set(TARGETNAME "${TARGETNAME}" PARENT_SCOPE)
endfunction()

# ------------------------------------------------------------------------------
# Public: besa_test_directory
#
# Creates and registers *runtime* unit tests from all files in a directory.
#
# Each file in DIR_NAME results in:
#   - an executable target named "<PREFIX>.<basename>"
#   - a CTest test with the same name that runs the executable
#   - the test gets LABELS set to LABELNAME
#   - the target links against every library in TARGET_LIB_LIST
#   - optional coverage registration
#
# Call signature (keyword-literal style; keywords are REQUIRED and positional):
#   besa_test_directory(
#     DIRECTORY        <dir>
#     TARGET_LIST      <varname>
#     PREFIX           <prefix>
#     LABELS           <label>
#     COVERAGE         <TRUE|FALSE>
#     COVERAGE_GROUP   <group_name>
#     CMDLINE          <...>
#   )
#
# Arguments:
#   DIRECTORY
#     Path to the directory (relative to this module dir or absolute).
#
#   TARGET_LIST
#     Name of a variable (in caller scope) that holds libraries to link against.
#     NOTE: The implementation expects the variable to be available as TARGET_LIB_LIST.
#     In practice, callers should ensure TARGET_LIB_LIST is set appropriately.
#
#   PREFIX
#     Namespace-like prefix for test target names.
#
#   LABELS
#     CTest label applied via set_property(TEST ... PROPERTY LABELS ...).
#
#   COVERAGE
#     "TRUE" enables coverage registration via besa_coverage_register_test().
#
#   COVERAGE_GROUP
#     Coverage grouping key passed to besa_coverage_register_test().
#
#   CMDLINE
#     Reserved for future use (currently unused).
#
# Filename conventions:
#   - If the computed TARGETNAME matches ".fail.t$" the test is expected to fail at runtime.
#   - If the computed TARGETNAME matches "disabled.t$|disabled.fail.t$" the test is disabled.
#
# Working directory:
#   Tests run with WORKING_DIRECTORY set to PROJECT_BINARY_DIR.
# ------------------------------------------------------------------------------
function(besa_test_directory
    DIRECTORY_LITERAL DIR_NAME
    TARGET_LIST_LITERAL TARGET_LIST
    PREFIX_LITERAL PREFIX
    LABELS_LITERAL LABELNAME
    COVERAGE_LITERAL COVERAGE
    COVERAGE_GROUP_LITERAL COVERAGE_GROUP
    CMDLINE_LITERAL CMDLINE
  )

  # Enforce keyword-literal usage to avoid silent argument mis-ordering.
  if(NOT DIRECTORY_LITERAL STREQUAL "DIRECTORY"
      OR NOT TARGET_LIST_LITERAL STREQUAL "TARGET_LIST"
      OR NOT PREFIX_LITERAL STREQUAL "PREFIX"
      OR NOT LABELS_LITERAL STREQUAL "LABELS"
      OR NOT COVERAGE_LITERAL STREQUAL "COVERAGE"
      OR NOT COVERAGE_GROUP_LITERAL STREQUAL "COVERAGE_GROUP"
      OR NOT CMDLINE_LITERAL STREQUAL "CMDLINE"
    )

    message(FATAL_ERROR "Incorrect usage of besa_test_directory
    DIRECTORY_LITERAL = ${DIRECTORY_LITERAL}
    TARGET_LIST_LITERAL = ${TARGET_LIST_LITERAL}
    PREFIX_LITERAL = ${PREFIX_LITERAL}
    LABELS_LITERAL = ${LABELS_LITERAL}
    COVERAGE_LITERAL = ${COVERAGE_LITERAL}
    COVERAGE_GROUP_LITERAL = ${COVERAGE_GROUP_LITERAL}
    CMDLINE_LITERAL = ${CMDLINE_LITERAL}
    ")

  endif()

  set(TARGET_LIB_LIST ${TARGET_LIST})

  # Resolve DIR_NAME to an absolute path for robust file globbing and target creation.
  file(REAL_PATH ${DIR_NAME} ABS_DIR_NAME BASE_DIRECTORY ${CMAKE_CURRENT_LIST_DIR})

  # Collect all files directly under the directory (no subdirectories).
  # CONFIGURE_DEPENDS triggers CMake reconfigure when directory contents change.
  file(GLOB SOURCE_LIST LIST_DIRECTORIES false
    RELATIVE ${ABS_DIR_NAME} CONFIGURE_DEPENDS ${DIR_NAME}/*)

  separate_arguments(CMDLINE UNIX_COMMAND "${CMDLINE}")

  foreach(SOURCE ${SOURCE_LIST})
    # Compute target/test name: "<PREFIX>.<basename>"
    besa_internal_unit_test_name(${SOURCE} ${PREFIX} TARGETNAME)

    # Derive a "test source directory" name used by besa_target_source_directory().
    # This strips extensions repeatedly to support filenames like:
    #   foo.test.cpp  -> foo
    #   foo.fail.t.cpp -> foo
    string(REGEX REPLACE "\\.[^.]*$" "" TESTDIRNAME ${SOURCE})
    string(REGEX REPLACE "\\.[^.]*$" "" TESTDIRNAME ${TESTDIRNAME})
    string(REGEX REPLACE "\\.[^.]*$" "" TESTDIRNAME ${TESTDIRNAME})

    # Create the runtime test executable.
    add_executable(${TARGETNAME} ${ABS_DIR_NAME}/${SOURCE})

    # Inform the builder utilities where the test "source directory" is.
    # This is typically used to configure include paths or compile definitions consistently.
    besa_target_source_directory(${TARGETNAME} PRIVATE ${ABS_DIR_NAME}/${TESTDIRNAME})

    # Register as a CTest test that runs the produced executable.
    add_test(
      NAME ${TARGETNAME}
      COMMAND $<TARGET_FILE:${TARGETNAME}> ${CMDLINE}
      WORKING_DIRECTORY ${PROJECT_BINARY_DIR}
    )

    # Apply CTest label(s).
    set_property(TEST ${TARGETNAME} PROPERTY LABELS ${LABELNAME})

    # Link against all libraries supplied by the caller (via TARGET_LIB_LIST).
    foreach(TARGET_LIB ${TARGET_LIB_LIST})
      target_link_libraries(${TARGETNAME} PRIVATE ${TARGET_LIB})
    endforeach()

    # Mark expected runtime failures (negative runtime tests).
    if(TARGETNAME MATCHES ".fail.t$")
      set_tests_properties(${TARGETNAME} PROPERTIES WILL_FAIL TRUE)
    endif()

    # Disable tests by name convention.
    if(TARGETNAME MATCHES "disabled.t$|disabled.fail.t$")
      set_tests_properties(${TARGETNAME} PROPERTIES DISABLED TRUE)
    endif()

    # Optional coverage registration.
    if(COVERAGE STREQUAL "TRUE")
      besa_coverage_register_test(${COVERAGE_GROUP} ${TARGETNAME} ${TARGETNAME})
    endif()

  endforeach()
endfunction()

# ------------------------------------------------------------------------------
# Public: besa_compile_test_directory
#
# Creates and registers *compile-only* tests from all files in a directory.
#
# Each file in DIR_NAME results in:
#   - an executable target (excluded from ALL/default build)
#   - a CTest test that runs: cmake --build . --target <target>
#     i.e. the "test" is whether the target can be built under current options.
#
# This is especially useful for:
#   - ensuring specific sources *do* compile under chosen build flags
#   - negative compile tests: enforcing that certain anti-patterns do *not* compile
#
# Call signature (keyword-literal style; keywords are REQUIRED and positional):
#   besa_compile_test_directory(
#     DIRECTORY   <dir>
#     TARGET_LIST <varname>
#     PREFIX      <prefix>
#     LABELS      <label>
#   )
#
# Arguments:
#   DIRECTORY
#     Path to the directory (relative to this module dir or absolute).
#
#   TARGET_LIST
#     Name of a variable (in caller scope) that holds libraries to link against.
#     NOTE: The implementation expects the variable to be available as TARGET_LIB_LIST.
#
#   PREFIX
#     Namespace-like prefix for generated target/test names.
#
#   LABELS
#     CTest label applied via set_property(TEST ... PROPERTY LABELS ...).
#
# Target naming:
#   The target name is constructed to be unique across directories:
#     "<PREFIX>.<relative_dir_from_module>.<file_basename_with_dots>"
#
# Filename conventions:
#   - If the computed TARGETNAME matches ".fail.t$" the compile test is expected to fail (WILL_FAIL TRUE).
#   - If the computed TARGETNAME matches "disabled.t$" or "disabled.fail.t$" the compile test is disabled.
# ------------------------------------------------------------------------------
function(besa_compile_test_directory
    DIRECTORY_LITERAL DIR_NAME
    TARGET_LIST_LITERAL TARGET_LIST
    PREFIX_LITERAL PREFIX
    LABELS_LITERAL LABELNAME
  )

  # Enforce keyword-literal usage.
  if(NOT DIRECTORY_LITERAL STREQUAL "DIRECTORY"
      OR NOT TARGET_LIST_LITERAL STREQUAL "TARGET_LIST"
      OR NOT PREFIX_LITERAL STREQUAL "PREFIX"
      OR NOT LABELS_LITERAL STREQUAL "LABELS"
    )

    message(FATAL_ERROR "Incorrect usage of add_test_directory
    DIRECTORY_LITERAL = ${DIRECTORY_LITERAL}
    TARGET_LIST_LITERAL = ${TARGET_LIST_LITERAL}
    PREFIX_LITERAL = ${PREFIX_LITERAL}
    LABELS_LITERAL = ${LABELS_LITERAL}
    ")

  endif()

  set(TARGET_LIB_LIST ${TARGET_LIST})

  # Resolve DIR_NAME to an absolute path for globbing and target creation.
  file(REAL_PATH ${DIR_NAME} ABS_DIR_NAME BASE_DIRECTORY ${CMAKE_CURRENT_LIST_DIR})
  file(
    GLOB SOURCE_FILE_LIST LIST_DIRECTORIES false
    RELATIVE ${ABS_DIR_NAME} CONFIGURE_DEPENDS ${DIR_NAME}/*)

  # Compute a stable relative directory name to embed into the target name.
  file(RELATIVE_PATH REL_DIR_NAME ${CMAKE_CURRENT_LIST_DIR} ${ABS_DIR_NAME})

  foreach(SRC_FILE ${SOURCE_FILE_LIST})
    # Build a unique target name:
    #   - strip extension
    #   - convert any directory separators to dots (in case SRC_FILE contains subpaths)
    #   - prefix with PREFIX and REL_DIR_NAME
    string(REGEX REPLACE "\\.[^.]*$" "" TARGETNAME ${SRC_FILE})
    string(REGEX REPLACE "/" "." TARGETNAME ${TARGETNAME})
    set(TARGETNAME "${PREFIX}.${REL_DIR_NAME}.${TARGETNAME}")

    # Create an executable target solely to validate compilation.
    add_executable(${TARGETNAME} ${ABS_DIR_NAME}/${SRC_FILE})

    # Derive a "test source directory" name used by besa_target_source_directory().
    # This strips extensions twice to support patterns like "*.fail.t.*".
    string(REGEX REPLACE "\\.[^.]*$" "" TESTDIRNAME ${SRC_FILE})
    string(REGEX REPLACE "\\.[^.]*$" "" TESTDIRNAME ${TESTDIRNAME})

    # Link against all libraries supplied by the caller (via TARGET_LIB_LIST).
    foreach(TARGET_LIB IN LISTS TARGET_LIB_LIST)
      target_link_libraries(${TARGETNAME} PRIVATE ${TARGET_LIB})
    endforeach()

    # Do not include these compile-test targets in the default build.
    set_target_properties(
      ${TARGETNAME} PROPERTIES EXCLUDE_FROM_ALL TRUE EXCLUDE_FROM_DEFAULT_BUILD
      TRUE)

    # Register a CTest test that *builds* the specific target.
    # This makes "ctest" drive compilation checks.
    add_test(NAME ${TARGETNAME} COMMAND ${CMAKE_COMMAND} --build . --target
      ${TARGETNAME} --config $<CONFIG>
      WORKING_DIRECTORY ${PROJECT_BINARY_DIR})

    # Apply CTest label(s).
    set_property(TEST ${TARGETNAME} PROPERTY LABELS ${LABELNAME})

    # Mark expected compile failures (negative compile tests).
    if(TARGETNAME MATCHES ".fail.t$")
      set_tests_properties(${TARGETNAME} PROPERTIES WILL_FAIL TRUE)
    endif()

    # Disable compile tests by name convention.
    if(TARGETNAME MATCHES "disabled.t$")
      set_tests_properties(${TARGETNAME} PROPERTIES DISABLED TRUE)
    endif()

    if(TARGETNAME MATCHES "disabled.fail.t$")
      set_tests_properties(${TARGETNAME} PROPERTIES DISABLED TRUE)
    endif()

    # Inform the builder utilities where the test "source directory" is (relative form here).
    besa_target_source_directory(${TARGETNAME} PRIVATE ${REL_DIR_NAME}/${TESTDIRNAME})
  endforeach()
endfunction()

