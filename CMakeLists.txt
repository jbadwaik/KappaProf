# --------------------------------------------------------------------------------------------------
# SPDX-License-Identifier: Apache-2.0
# --------------------------------------------------------------------------------------------------
cmake_minimum_required(VERSION 4.3)
project(kprof VERSION 0.1.0 LANGUAGES CXX)
list(PREPEND CMAKE_PREFIX_PATH "${PROJECT_SOURCE_DIR}/cmake")
include(CTest)
find_package(besa CONFIG REQUIRED COMPONENTS feature)
find_package(besa CONFIG REQUIRED COMPONENTS mode)

# --------------------------------------------------------------------------------------------------
# Build Options
# --------------------------------------------------------------------------------------------------
option(BUILD_TESTING        "Enable testing for kprof"   ON)

set(PROJECT_FEATURES  "perf" CACHE STRING "Features to enable for kprof")

besa_feature_register(PROJECT_FEATURES_ARRAY perf "Build with Perf Support" OFF)
besa_feature_register(PROJECT_FEATURES_ARRAY examples "Build examples (enables all examples)" OFF)
besa_feature_register(PROJECT_FEATURES_ARRAY examples_gemm "Build GEMM examples" OFF)

set(PROJECT_BLAS_BACKEND "none" CACHE STRING "BLAS backend to use for examples")
besa_mode(PROJECT_BLAS_BACKEND VALUES "openblas;blis;amdblis;none" DESCRIPTION "BLAS backend to use")
# --------------------------------------------------------------------------------------------------
# Processing Build Options
# --------------------------------------------------------------------------------------------------
include(bs/features.cmake)

# --------------------------------------------------------------------------------------------------
# Build Script
# --------------------------------------------------------------------------------------------------
find_package(besa CONFIG REQUIRED COMPONENTS builder)
find_package(besa CONFIG REQUIRED COMPONENTS test)

add_library(libkprof)
add_library(kprof::libkprof ALIAS libkprof)
set_target_properties(libkprof PROPERTIES OUTPUT_NAME kprof)
besa_feature_apply_to_target(libkprof PROJECT_PARTS PUBLIC KPROF_PARTS)

add_subdirectory(src)

add_library(libkprof_devkit)
set_target_properties(libkprof_devkit PROPERTIES OUTPUT_NAME kprof_devkit)
add_subdirectory(devkit)

add_subdirectory(examples)

if(BUILD_TESTING)
  enable_testing()
  add_subdirectory(tests)
endif()


