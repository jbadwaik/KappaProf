# --------------------------------------------------------------------------------------------------
# SPDX-License-Identifier: Apache-2.0
# --------------------------------------------------------------------------------------------------

# --------------------------------------------------------------------------------------------------
# Process Project Features
# --------------------------------------------------------------------------------------------------
besa_feature_process(PROJECT_FEATURES VALUES "${PROJECT_FEATURES_ARRAY}" DESCRIPTION "Project Features")

# --------------------------------------------------------------------------------------------------
# Define Disjoint Parts of the Project
# --------------------------------------------------------------------------------------------------
set(PROJECT_PARTS "" CACHE STRING "Disjoint set of capabilities")
besa_feature_register(PROJECT_PARTS_ARRAY perf "Support for Catch2 related test functions")

if(PROJECT_FEATURES_PERF)
  list(APPEND PROJECT_PARTS "perf")
endif()

# --------------------------------------------------------------------------------------------------
# Maps between Features and Capabilities
# --------------------------------------------------------------------------------------------------

list(REMOVE_DUPLICATES PROJECT_PARTS)
besa_feature_process(PROJECT_PARTS VALUES "${PROJECT_PARTS_ARRAY}" DESCRIPTION "Project Parts")


# --------------------------------------------------------------------------------------------------
# External Dependencies for Parts of the Project
# --------------------------------------------------------------------------------------------------


# --------------------------------------------------------------------------------------------------
# Define Devkits of the Project
# --------------------------------------------------------------------------------------------------
set(PROJECT_DEVKITS "" CACHE STRING "Devkit components to build")
besa_feature_register(PROJECT_DEVKITS_ARRAY catch2 "Build the kprof_devkit library")

# --------------------------------------------------------------------------------------------------
# Map between Project Features and Devkits
# --------------------------------------------------------------------------------------------------
if(BUILD_TESTING)
  list(APPEND PROJECT_DEVKITS "catch2")
endif()



list(REMOVE_DUPLICATES PROJECT_DEVKITS)
besa_feature_process(PROJECT_DEVKITS VALUES "${PROJECT_DEVKITS_ARRAY}" DESCRIPTION "Project Devkits")
# --------------------------------------------------------------------------------------------------
# External Dependencies for Devkits
# --------------------------------------------------------------------------------------------------
if(PROJECT_DEVKITS_CATCH2)
  find_package(Catch2 REQUIRED)
endif()


#find_package(PkgConfig REQUIRED)
#
#if(PROJECT_FEATURES_EXAMPLES_GEMM)
#  if(PROJECT_BLAS_BACKEND STREQUAL "openblas")
#    pkg_check_modules(OpenBLAS REQUIRED IMPORTED_TARGET openblas)
#    target_link_libraries(libkprof PRIVATE PkgConfig::OpenBLAS)
#  else()
#    message(FATAL_ERROR "Unsupported BLAS backend: ${PROJECT_BLAS_BACKEND}")
#  endif()
#endif()
