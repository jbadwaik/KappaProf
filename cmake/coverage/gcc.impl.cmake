# --------------------------------------------------------------------------------------------------
# SPDX-License-Identifier: Apache-2.0
# Copyright (C) 2024 Jayesh Badwaik <j.badwaik@fz-juelich.de>
# --------------------------------------------------------------------------------------------------
message(DEBUG "Computing Coverage for Test Group ${GROUP_NAME}")
file(GLOB_RECURSE GCDA_FILE_LIST LIST_DIRECTORIES false
  RELATIVE ${COVERAGE_OUTDIR}/gcda ${COVERAGE_OUTDIR}/gcda/*.gcda)

foreach(GCDA_FILE ${GCDA_FILE_LIST})
  string(REGEX REPLACE ".gcda$" ".gcno" GCNO_FILE ${GCDA_FILE})
  set(SOURCE_GCNO_FILE "/${GCNO_FILE}")
  set(DESTINATION_GCNO_FILE "${COVERAGE_OUTDIR}/gcda/${GCNO_FILE}")
  set(FULL_GCDA_FILE "${COVERAGE_OUTDIR}/${GCDA_FILE}")
  file(COPY_FILE ${SOURCE_GCNO_FILE} ${DESTINATION_GCNO_FILE})

endforeach()

execute_process(
  COMMAND
  ${BESA_LCOV} --derive-func-data --rc branch_coverage=1 --directory
  ${COVERAGE_OUTDIR}/gcda --capture --output-file ${GROUP_NAME}.info --profile ${GROUP_NAME}.json
  WORKING_DIRECTORY ${COVERAGE_OUTDIR}/)

execute_process(
  COMMAND
  ${BESA_GCOVR} --root ${SOURCE_DIR} ${COVERAGE_OUTDIR} --json-summary summary.json
  WORKING_DIRECTORY ${COVERAGE_OUTDIR}/
  )

execute_process(
  COMMAND ${BESA_GENHTML} --branch-coverage -o ${COVERAGE_OUTDIR}/html
  ${GROUP_NAME}.info WORKING_DIRECTORY ${COVERAGE_OUTDIR}/)

file(WRITE ${COVERAGE_OUTDIR}/compiler "GNU\n")

message(DEBUG "Computing Coverage for Test Group ${GROUP_NAME} - Done")
