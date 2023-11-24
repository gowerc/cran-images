
#
# NOTE
#
# If you are updating to more recent versions you need to edit the following locations
#    - URL for clang download
#    - FROM statement for latest debian version
#    - deb-src URLS for debians latest sources
#
#


FROM debian:bookworm


RUN apt update && \
    apt install -y git cmake make xz-utils wget libcurl4-openssl-dev curl


RUN mkdir -p /tools && \
    cd /tools && \
    wget https://github.com/llvm/llvm-project/releases/download/llvmorg-17.0.5/clang+llvm-17.0.5-x86_64-linux-gnu-ubuntu-22.04.tar.xz && \
    tar -xJf *.tar.xz &&\
    rm *.tar.xz  &&\
    mv clang* clang


ENV PATH="/tools/clang/bin:$PATH"

RUN cat >> /etc/apt/sources.list <<EOF
deb-src http://deb.debian.org/debian bookworm main non-free-firmware
deb-src http://deb.debian.org/debian-security/ bookworm-security main non-free-firmware
deb-src http://deb.debian.org/debian bookworm-updates main non-free-firmware
EOF

RUN apt update && \
    apt build-dep -y r-base


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
RUN cat >> config.site <<EOF
CFLAGS='-O3 -Wall -pedantic -Wp,-D_FORTIFY_SOURCE=3'
FFLAGS='-O2 -pedantic'
CXXFLAGS='-O3 -Wall -pedantic -frtti -Wp,-D_FORTIFY_SOURCE=3'
CPPFLAGS='-isystem /usr/local/clang/include -isystem /tools/clang/include'
LDFLAGS='-L/lib64 -L/tools/clang/lib -L/lib/x86_64-linux-gnu'
CC='clang'
CXX='clang++'
EOF


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





## Additional system libraries for various R packages
RUN apt install -y \
        libomp5 libomp-dev libxml2-dev libssl-dev \
        libv8-dev vim libicu-dev zlib1g-dev  \
        libfontconfig1-dev libfreetype6-dev libfribidi-dev \
        libharfbuzz-dev libjpeg-dev libpng-dev libtiff-dev \
        pandoc libgit2-dev


# Install additional libraries into side directory so that then can
# be easily ignored by end users if needed
RUN mkdir library_extra && \
    cat >>  $(Rscript -e "cat(R.home())")/etc/Rprofile.site  <<EOF
options(repos = c(CRAN = "http://cran.rstudio.com"))
.libPaths("$(pwd)/library_extra")

EOF


# Optional - Install common libraries to save people having to 
#            manually compile them each time
RUN Rscript - <<EOF
install.packages(c(
    'mmrm',
    'bookdown',
    'devtools',
    'tidyverse',
    'tidymodels',
    'mvtnorm', 
    'R.rsp',
    'rstan',
    'rstantools',
    'emmeans',
    'rbmi',
    'shiny',
    'renv',
    'furrr',
    'languageserver',
    'htmlTable',
    'brms',
    'dbplyr',
    'dtplyr'
    ),dependencies = TRUE)
EOF

WORKDIR /

