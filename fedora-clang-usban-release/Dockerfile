
#
#
# TODO - This image needs to be reworked (see fedora-clang-devel for guidance)
#
#

FROM fedora:latest

RUN dnf -y install clang gfortran yum-utils
RUN yum-builddep -y R


ENV R_VERSION="4.1.3"

### CRAN UBSAN check variables
ENV ASAN_OPTIONS="detect_leaks=0:detect_odr_violation=0"
ENV UBSAN_OPTIONS="print_stacktrace=1"
ENV RJAVA_JVM_STACK_WORKAROUND="0"
ENV RGL_USE_NULL="true"
ENV R_DONT_USE_TK="true"

### CRAN compiler flags
ENV CC="clang -fsanitize=address,undefined -fno-sanitize=float-divide-by-zero -fno-sanitize=alignment -fno-omit-frame-pointer"
ENV CXX="clang++ -fsanitize=address,undefined -fno-sanitize=float-divide-by-zero -fno-sanitize=alignment -fno-omit-frame-pointer -frtti"
ENV CFLAGS="-g -O3 -Wall -pedantic"
ENV FFLAGS="-g -O2 -mtune=native"
ENV CXXFLAGS="-g -O3 -Wall -pedantic"
ENV MAIN_LD="clang++ -fsanitize=undefined,address"


### Download R
RUN curl -O https://cran.r-project.org/src/base/R-4/R-${R_VERSION}.tar.gz &&\
    tar -xzvf R-${R_VERSION}.tar.gz

WORKDIR /R-$R_VERSION


### Build R from source
RUN ./configure \
    --prefix=/opt/R/${R_VERSION} \
    --enable-memory-profiling \
    --enable-R-shlib \
    --with-blas \
    --with-lapack

RUN make &&\
    make install

RUN ln -s /opt/R/${R_VERSION}/bin/R /usr/local/bin/R &&\
    ln -s /opt/R/${R_VERSION}/bin/Rscript /usr/local/bin/Rscript

WORKDIR /

### Set user configuration files
# COPY ./Makevars /root/.R/
# COPY ./.valgrindrc do_makename.supp wcsrtombs.supp /root/
COPY ./Rprofile.site  /
RUN mv Rprofile.site $(Rscript -e "cat(R.home())")/etc/

### Install package dependencies
RUN dnf install -y \
    openssl-devel \
    cmake \
    git \
    vim


### Install Required R packages
RUN Rscript -e 'options(warn=2); install.packages("dplyr")'
RUN Rscript -e 'options(warn=2); install.packages("purrr")'
RUN Rscript -e 'options(warn=2); install.packages("lubridate")'
RUN Rscript -e 'options(warn=2); install.packages("rmarkdown")'
RUN Rscript -e 'options(warn=2); install.packages("knitr")'
RUN Rscript -e 'options(warn=2); install.packages("ggplot2")'
RUN Rscript -e 'options(warn=2); install.packages("tidyr")'
RUN Rscript -e 'options(warn=2); install.packages("devtools")'
RUN Rscript -e 'options(warn=2); install.packages("mvtnorm")'
RUN Rscript -e 'options(warn=2); install.packages("emmeans")'
RUN Rscript -e 'options(warn=2); install.packages("R.rsp")'
RUN Rscript -e 'options(warn=2); install.packages("bookdown")'
RUN Rscript -e 'options(warn=2); install.packages("rstan")'
RUN Rscript -e 'options(warn=2); install.packages("rstantools")'
RUN Rscript -e 'options(warn=2); install.packages("assertthat")'
RUN Rscript -e 'options(warn=2); install.packages("covr")'
RUN Rscript -e 'options(warn=2); install.packages("glmmTMB")'
RUN Rscript -e 'options(warn=2); install.packages("languageserver")'


