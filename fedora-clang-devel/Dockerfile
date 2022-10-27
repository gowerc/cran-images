# Requirements for image are drawn from:
#     https://www.stats.ox.ac.uk/pub/bdr/Rconfig/r-devel-linux-x86_64-fedora-clang


FROM fedora:latest

RUN dnf -y install clang gfortran yum-utils
RUN yum-builddep -y R


ENV R_VERSION="devel"


### CRAN compiler flags
ENV CC="clang -fsanitize=address,undefined -fno-sanitize=float-divide-by-zero -fno-sanitize=alignment -fno-omit-frame-pointer"
ENV CXX="clang++ -fsanitize=address,undefined -fno-sanitize=float-divide-by-zero -fno-sanitize=alignment -fno-omit-frame-pointer -frtti"
ENV CFLAGS="-O3 -Wall -pedantic"
ENV FFLAGS="-O2 -mtune=native -Wall -pedantic"
ENV CXXFLAGS="-O3 -Wall -pedantic -frtti"
ENV CPPFLAGS="-isystem /usr/local/clang/include"
ENV LDFLAGS="-L/usr/local/clang/lib64 -L/usr/local/lib64"


### Download R
RUN curl -O https://stat.ethz.ch/R/daily/R-${R_VERSION}.tar.gz &&\
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
COPY ./Rprofile.site  /
RUN mv /Rprofile.site $(Rscript -e "cat(R.home())")/etc/

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
RUN Rscript -e 'options(warn=2); install.packages("languageserver")'
RUN Rscript -e 'options(warn=2); install.packages("mmrm")'



ENV _R_CHECK_INSTALL_DEPENDS_="true"
ENV _R_CHECK_SUGGESTS_ONLY_="true"
ENV _R_CHECK_NO_RECOMMENDED_="true"
ENV _R_CHECK_DOC_SIZES2_="true"
ENV _R_CHECK_DEPRECATED_DEFUNCT_="true"
ENV _R_CHECK_SCREEN_DEVICE_="true"
ENV _R_CHECK_REPLACING_IMPORTS_="true"
ENV _R_CHECK_TOPLEVEL_FILES_="true"
ENV _R_CHECK_DOT_FIRSTLIB_="true"
ENV _R_CHECK_RD_LINE_WIDTHS_="true"
ENV _R_CHECK_S3_METHODS_NOT_REGISTERED_="true"
ENV _R_CHECK_OVERWRITE_REGISTERED_S3_METHODS_="true"
ENV _R_CHECK_CODE_USAGE_WITH_ONLY_BASE_ATTACHED_="TRUE"
ENV _R_CHECK_NATIVE_ROUTINE_REGISTRATION_="true"
ENV _R_CHECK_FF_CALLS_="registration"
ENV _R_CHECK_PRAGMAS_="true"
ENV _R_CHECK_COMPILATION_FLAGS_="true"
ENV _R_CHECK_R_DEPENDS_="true"
ENV _R_CHECK_PACKAGES_USED_IN_TESTS_USE_SUBDIRS_="true"
ENV _R_CHECK_SHLIB_OPENMP_FLAGS_="true"
ENV _R_CHECK_CODE_ASSIGN_TO_GLOBALENV_="true"
ENV _R_CHECK_CODE_DATA_INTO_GLOBALENV_="true"
ENV _R_CHECK_PKG_SIZES_="true"
ENV _R_CHECK_LIMIT_CORES_="true"
ENV _R_S3_METHOD_LOOKUP_BASEENV_AFTER_GLOBALENV_="true"
ENV _R_CHECK_AUTOCONF_="true"
ENV _R_CHECK_THINGS_IN_CHECK_DIR_="true"
ENV _R_CHECK_THINGS_IN_TEMP_DIR_="true"
ENV _R_CHECK_THINGS_IN_TEMP_DIR_EXCLUDE_="^ompi"
ENV _R_CHECK_BASHISMS_="true"
ENV _R_CHECK_ORPHANED_="true"
ENV _R_CHECK_DEPENDS_ONLY_DATA_="true"
ENV _R_CHECK_XREFS_PKGS_ARE_DECLARED_="true"
ENV _R_CHECK_MATRIX_DATA_="true"
ENV _R_CHECK_RD_VALIDATE_RD2HTML_="true"
ENV _R_CHECK_RD_MATH_RENDERING_="true"
ENV _R_CHECK_XREFS_PKGS_ARE_DECLARED_="true"





