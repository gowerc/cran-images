


FROM fedora:39

ENV CLANG_VERSION=17.0.5

RUN dnf install -y git cmake make xz wget curl binutils gcc g++

RUN mkdir -p /tools/clang && \
    cd /tools/clang && \
    git clone --depth=1 --branch llvmorg-${CLANG_VERSION} https://github.com/llvm/llvm-project.git . && \
    mkdir build && \
    cd build && \
    cmake -DLLVM_ENABLE_PROJECTS=clang -DCMAKE_BUILD_TYPE=Release -G "Unix Makefiles" ../llvm && \
    make



ENV PATH="/tools/clang/build/bin:$PATH"

RUN dnf install -y \
    'dnf-command(builddep)' \
    java \
    openssl-devel \
    libcurl-devel \
    freetype-devel \
    fribidi-devel \
    harfbuzz-devel \
    libpng-devel \
    fontconfig-devel \
    libxml2-devel \
    libicu-devel \
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
    curl -O https://cran.r-project.org/src/base-prerelease/R-devel.tar.gz && \
    tar -xzvf R-devel.tar.gz  && \
    rm R-devel.tar.gz && \
    mv R-devel R

WORKDIR /tools/R


# Compiler options set in order to try and match CRANs fedora server
# https://www.stats.ox.ac.uk/pub/bdr/Rconfig/r-devel-linux-x86_64-fedora-clang
RUN echo -e "\n\
CFLAGS='-O3 -Wall -pedantic -Wp,-D_FORTIFY_SOURCE=3' \n\
FFLAGS='-O2 -pedantic' \n\
CXXFLAGS='-O3 -Wall -pedantic -frtti -Wp,-D_FORTIFY_SOURCE=3' \n\
CPPFLAGS='-isystem /usr/local/clang/include' \n\
LDFLAGS='-L/lib64 -L/tools/clang/build/lib' \n\
CC='clang' \n\
CXX='clang++'\n" >> config.site



# # Only required if compiling < R4.3.x
#
# # Fedora 39 dnf provides curl8 but the R configure script explicitly looks for
# # curl7. Curl8 is apparently regarded as backwards compatible so we disable this
# # test by allowing major versions >7
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


# Install additional libraries into side directory so that then can
# be easily ignored by end users if needed
RUN mkdir library_extra && \
    echo -e "\n \
options(repos = c(CRAN = \"http://cran.rstudio.com\"))\n\
.libPaths(\"$(pwd)/library_extra\") \n \
" >> $(Rscript -e "cat(R.home())")/etc/Rprofile.site

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
    'dtplyr'\
    ), dependencies = TRUE)"

WORKDIR /
