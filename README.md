

# CRAN Images

This project attempts to create docker images that more closely allign with CRANs test machines.
This attempts to supplement the excellent work done by [Rhub](https://github.com/r-hub/rhub-linux-builders/blob/master/fedora-clang/Dockerfile).
Unfortunately CRAN use non-standard compiler versions for example clang-17 on Fedora when the
default sources only provide clang-16.

This repo therefore creates images that try to have some of these oddities so that we can attempt
to re-create bugs that are only seen on CRAN and not elsewhere. 



