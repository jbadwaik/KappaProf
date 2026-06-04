<!--
- SPDX-License-Identifier: Apache-2.0
-->

# kprof : A Lightweight Composable Profiling Library


## Build Instructions


### Installing Dependencies with Spack

```
# Install Spack
export DEP_ROOT=<some-location>
git clone --depth 1 --branch v1.1.1 https://github.com/spack/spack.git "${DEP_ROOT}/spack"
git clone --depth 1 --branch develop https://github.com/jbadwaik/spack-packages.git "${DEP_ROOT}/spack-packages"

# Source  Spack
source "${DEP_ROOT}/spack/share/spack/setup-env.sh"
spack add repo "${DEP_ROOT}/spack-packages/repos/spack_repo/builtin"

# Activate the Spack environment
spack env activate .
spack install
```

### Build and Run

```
cmake -B ../build -S . -DBUILD_TESTING=On
cmake --build ../build -j 8
ctest --test-dir ../build
```





