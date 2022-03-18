
## R is built with

export ASAN_OPTIONS 'detect_leaks=0:detect_odr_violation=0'
export UBSAN_OPTIONS 'print_stacktrace=1'
export RJAVA_JVM_STACK_WORKAROUND 0
export RGL_USE_NULL true
export R_DONT_USE_TK true
export CC="clang -fsanitize=address,undefined -fno-sanitize=float-divide-by-zero -fno-sanitize=alignment -fno-omit-frame-pointer"
export CXX="clang++ -fsanitize=address,undefined -fno-sanitize=float-divide-by-zero -fno-sanitize=alignment -fno-omit-frame-pointer -frtti"
export CFLAGS="-g -O3 -Wall -pedantic"
export FFLAGS="-g -O2 -mtune=native"
export CXXFLAGS="-g -O3 -Wall -pedantic"
export MAIN_LD="clang++ -fsanitize=undefined,address"




docker run --rm -it cran-fed bash

git clone https://github.com/insightsengineering/rbmi.git

cd rbmi


export SANITISE_SLIM=""

export CC="clang -std=gnu99 -fsanitize=undefined,address -fno-omit-frame-pointer"
export CXX="clang++ -fsanitize=undefined,address -fno-omit-frame-pointer"
export FC="gfortran -fsanitize=undefined,address"
R CMD build .
R CMD check *.tar.gz


