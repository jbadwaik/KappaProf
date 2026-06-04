# --------------------------------------------------------------------------------------------------
# SPDX-License-Identifier: Apache-2.0
# --------------------------------------------------------------------------------------------------
besa_test_directory(
  DIRECTORY cpp
  TARGET_LIST "libkprof_test"
  PREFIX "test.unit.cpp"
  LABELS "unit,production"
  COVERAGE TRUE
  COVERAGE_GROUP "unit"
  CMDLINE "--input ${PROJECT_SOURCE_DIR}/tests/share/data --output ${PROJECT_BINARY_DIR}/output/tests/"
)


if(PROJECT_PARTS_PERF)
  besa_test_directory(
    DIRECTORY perf
    TARGET_LIST "libkprof_test"
    PREFIX "test.unit.perf"
    LABELS "unit,production"
    COVERAGE TRUE
    COVERAGE_GROUP "unit"
    CMDLINE "--input ${PROJECT_SOURCE_DIR}/tests/share/data --output ${PROJECT_BINARY_DIR}/output/tests/"
  )
endif()
