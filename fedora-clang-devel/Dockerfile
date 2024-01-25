


################################
#
# Base
#   - Installing the clang + fortran compiler
#
#
#


FROM fedora:36 as base

## Tracking commit as specified in https://www.stats.ox.ac.uk/pub/bdr/clang18/mmrm.out
ENV CLANG_COMMIT=8e7f073eb42c92aa7a2b651ca314d7fcebf296e3

## Minimal list of software to compile clang
RUN dnf install -y git cmake make xz wget curl binutils gcc g++ libcxx-devel perl

RUN mkdir -p /tools/clang && \
    cd /tools/clang && \
    git clone --depth=1 https://github.com/llvm/llvm-project.git . && \
    git fetch --depth=1 origin ${CLANG_COMMIT} && \
    git switch -c mybranch ${CLANG_COMMIT} && \
    mkdir build && \
    cd build && \
    cmake \
        -G "Unix Makefiles" \
        -D CMAKE_BUILD_TYPE=Release \
        -D LLVM_ENABLE_PROJECTS="clang;mlir;flang;openmp" \
        -D LLVM_ENABLE_RUNTIMES="compiler-rt" \
        ../llvm && \
    make -j4

## These were additional arguments used to compile clang with libc++ but
## was unable to get them to work
        # -D CMAKE_CXX_COMPILER=clang-14 \
        # -D CMAKE_CXX_FLAGS=-stdlib=libc++ \

ENV PATH="/tools/clang/build/bin:$PATH"






################################
#
# Core
#   - Installing R and other essential software
#
#
#


FROM base as core

## Full list found at: https://cran.r-project.org/src/base-prerelease/ 
ENV R_URL=https://cran.r-project.org/src/base-prerelease/R-devel.tar.gz

## Set url to download pandoc from
ENV PANDOC_URL=https://github.com/jgm/pandoc/releases/download/3.1.11.1/pandoc-3.1.11.1-linux-amd64.tar.gz


## Install all system library requirements for installing R and its packages
RUN dnf install -y \
    'dnf-command(builddep)' \
    java-17-openjdk java-17-openjdk-devel \
    openssl-devel \
    libcurl-devel \
    diffutils \
    texlive \
    freetype-devel \
    fribidi-devel \
    harfbuzz-devel \
    libpng-devel \
    fontconfig-devel \
    libxml2-devel \
    libicu-devel \
    tidy \
    rsync \
    ed \
    libomp-devel \
    vim \
    libjpeg-turbo-devel \
    zlib-devel \
    libtiff-devel \
    v8-devel \
    git \
    libgit2-devel &&\
    dnf builddep -y R

# Get R source code
# Change URL to specific R release - currently set to "DEVEL"
RUN cd /tools && \
    curl -O ${R_URL} && \
    tar -xzvf *.tar.gz  && \
    rm -f *.tar.gz && \
    mv R-devel R

WORKDIR /tools/R


#
# Compiler options set in order to try and match CRANs fedora server
# https://www.stats.ox.ac.uk/pub/bdr/Rconfig/r-devel-linux-x86_64-fedora-clang
#
# Note that some specific deviations to the above link have been made:
#
# The flags `-fsanitize=pointer-overflow -fsanitize-trap=pointer-overflow` were
# added as they appear to be undocumented options that are used by CRAN
# https://fosstodon.org/@gaborcsardi/111798433935952962
#
# Several packages require specific versions of Cpp so we added the relevant
# flags to the CXX*FLAGS variables
# 
# Several of the packages that required specific versions of Cpp failed to compile
# without the `-fPIC` flag. This only seemed to affect packages compiled with CPP11 and CPP17
#
# As mentioned in the CRAN documentation the compiled version of Clang links to stdlibc++
# thus we set the -stdlib=libc++ flag to ensure we link to the LLVM stdlib
# 
# The CRAN machine specific library paths were removed as they are specific to their machine only
# Instead they were updated to point to the correct directories within this image
# 
# To match the clang-18 machine we also need to set `FC=flang-new`. This is the only
# machine that uses this compiler.
#
# Openmp is built as part of the LLVM compiler tool chain. Need to manually add the path
# the the omp.h header files as it is not in clangs default search path. e.g
# add `-I/tools/clang/build/projects/openmp/runtime/src` to CXXFLAGS
#


RUN mkdir $HOME/.R
RUN echo -e "\n\
PKG_CFLAGS+=-fsanitize=pointer-overflow -fsanitize-trap=pointer-overflow \n\
CFLAGS=-O3 -Wall -pedantic -Wp,-D_FORTIFY_SOURCE=3 \n\
FFLAGS=-O2 -pedantic \n\
CXXFLAGS=-O3 -Wall -pedantic -frtti -Wp,-D_FORTIFY_SOURCE=3 -I/tools/clang/build/projects/openmp/runtime/src\n\
LDFLAGS=-L/lib64 -L/tools/clang/build/lib\n\
FC=flang-new \n\
CC=clang \n\
CXX=clang++ -stdlib=libc++ \n\
CXX11=clang++ -stdlib=libc++ -std=c++11 -fPIC\n\
CXX14=clang++ -stdlib=libc++ -std=c++14\n\
CXX17=clang++ -stdlib=libc++ -std=c++17 -fPIC\n\
CXX11FLAGS=-O3 -Wall -pedantic -frtti -Wp,-D_FORTIFY_SOURCE=3 \n\
CXX14FLAGS=-O3 -Wall -pedantic -frtti -Wp,-D_FORTIFY_SOURCE=3 \n\
CXX17FLAGS=-O3 -Wall -pedantic -frtti -Wp,-D_FORTIFY_SOURCE=3 \n\
" > $HOME/.R/Makevars
RUN cat $HOME/.R/Makevars >> config.site

# # The following is only required if compiling < R4.3.x
#
# # Fedora 39 dnf provides curl8 but the R configure script explicitly looks for
# # curl7. Curl8 is apparently regarded as backwards compatible so we disable this
# # test by modifying the configure script to allow major versions >7
# # src = https://unix.stackexchange.com/a/758031
#
# RUN awk '/> 7/ { c = 1 } !/> 7/ && c { print("  exit(0);"); c = 0; next; } 1' \
#     configure > configure.new && \
#     mv configure.new configure
#

RUN ./configure \
    --prefix=/opt/R/${R_VERSION} \
    --enable-R-shlib \
    --enable-memory-profiling \
    --with-blas \
    --without-lapack \
    --with-libdeflate-compression


RUN make && \
    make install


RUN ln -s $(pwd)/bin/R /usr/local/bin/R && \
    ln -s $(pwd)/bin/Rscript /usr/local/bin/Rscript

## Install additional libraries into side directory so that then can
## be easily ignored by end users if needed
## ---
## Have currently disabled this as it doesn't play well with `R CMD build`
## which runs with `--vanilla` which disables the site profile and thus causes
## vignette building to fail as none of the site packages can be found
## ---
RUN mkdir library_extra && \
    echo -e "\n \
options(repos = c(CRAN = \"https://cloud.r-project.org\"))\n\
# .libPaths(\"$(pwd)/library_extra\") \n \
" >> $(Rscript -e "cat(R.home())")/etc/Rprofile.site


# Use binary distribution of latest pandoc as per CRAN build comments
RUN cd /tools && \
    wget ${PANDOC_URL} && \
    tar -xzvf *.tar.gz  && \
    rm -f *.tar.gz && \
    mv pandoc-* pandoc
RUN ln -s /tools/pandoc/bin/pandoc /usr/local/bin/pandoc





################################
#
# Extended
#   - Installing nice-to have R libraries
#
#
#


FROM core as extended

# Build V8 using GCC as it cannot be built against clang + libc++
# First install GCC dependencies
RUN Rscript -e "install.packages(c(\
    'Rcpp',\
    'jsonlite', \
    'curl' \
    ))"
RUN echo -e "\n\
PKG_CFLAGS+=-fsanitize=pointer-overflow -fsanitize-trap=pointer-overflow \n\
CXX17=g++ -std=c++17 -fPIC -I/usr/include -L/usr/lib64 \n\
CXX17FLAGS=-O3 -Wall -pedantic -frtti -Wp,-D_FORTIFY_SOURCE=3 \n\
" > $HOME/.R/Makevars_v8
RUN R_MAKEVARS_USER=$HOME/.R/Makevars_v8 Rscript -e "install.packages('V8')"



# Option - Install common libraries to save people having to 
#          manually compile them each time
RUN Rscript -e "install.packages(c(\
    'mmrm',\
    'bookdown',\
    'devtools',\
    'tidyverse',\
    'tidymodels',\
    'mvtnorm', \
    'R.rsp',\
    'rstan',\
    'rstantools',\
    'emmeans',\
    'rbmi',\
    'shiny',\
    'renv',\
    'furrr',\
    'languageserver',\
    'htmlTable',\
    'brms',\
    'dbplyr',\
    'nlme',\
    'clubSandwich',\
    'glmmTMB',\
    'dtplyr'\
    ), dependencies = TRUE)"



# Set environment variables to mimic CRANs R CMD check

ENV OMP_THREAD_LIMIT=2
ENV _R_CHECK_INSTALL_DEPENDS_=true
ENV _R_CHECK_SUGGESTS_ONLY_=true
ENV _R_CHECK_NO_RECOMMENDED_=true
ENV _R_CHECK_DOC_SIZES2_=true
ENV _R_CHECK_DEPRECATED_DEFUNCT_=true
ENV _R_CHECK_SCREEN_DEVICE_=warn
ENV _R_CHECK_REPLACING_IMPORTS_=true
ENV _R_CHECK_TOPLEVEL_FILES_=true
ENV _R_CHECK_DOT_FIRSTLIB_=true
ENV _R_CHECK_RD_LINE_WIDTHS_=true
ENV _R_CHECK_S3_METHODS_NOT_REGISTERED_=true
ENV _R_CHECK_OVERWRITE_REGISTERED_S3_METHODS_=true
ENV _R_CHECK_CODE_USAGE_WITH_ONLY_BASE_ATTACHED_=TRUE
ENV _R_CHECK_NATIVE_ROUTINE_REGISTRATION_=true
ENV _R_CHECK_FF_CALLS_=registration
ENV _R_CHECK_PRAGMAS_=true
ENV _R_CHECK_COMPILATION_FLAGS_=true
ENV _R_CHECK_R_DEPENDS_=true
ENV _R_CHECK_PACKAGES_USED_IN_TESTS_USE_SUBDIRS_=true
ENV _R_CHECK_SHLIB_OPENMP_FLAGS_=true
ENV _R_CHECK_BROWSER_NONINTERACTIVE_=true
ENV _R_CHECK_CODE_ASSIGN_TO_GLOBALENV_=true
ENV _R_CHECK_CODE_DATA_INTO_GLOBALENV_=true
ENV _R_CHECK_PKG_SIZES_ true
ENV _R_CHECK_LIMIT_CORES_=true
ENV _R_S3_METHOD_LOOKUP_BASEENV_AFTER_GLOBALENV_=true
ENV _R_CHECK_AUTOCONF_=true
ENV _R_CHECK_THINGS_IN_CHECK_DIR_=true
ENV _R_CHECK_THINGS_IN_TEMP_DIR_=true
ENV _R_CHECK_THINGS_IN_TEMP_DIR_EXCLUDE_="^ompi"
ENV _R_CHECK_BASHISMS_=true
ENV _R_CHECK_ORPHANED_=true
ENV _R_CHECK_DEPENDS_ONLY_DATA_=true
ENV _R_CHECK_XREFS_PKGS_ARE_DECLARED_=true
ENV _R_CHECK_DEPENDS_ONLY_DATA_=true
ENV _R_CHECK_BOGUS_RETURN_=true
ENV _R_CHECK_MATRIX_DATA_=TRUE
ENV _R_CHECK_RD_VALIDATE_RD2HTML_=true
ENV _R_CHECK_RD_MATH_RENDERING_=true

WORKDIR /




