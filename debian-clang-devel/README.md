# CRAN Debian-Clang-Devel


This DockerFile attempts to re-create the CRAN [Debian-Clang-Devel](https://www.stats.ox.ac.uk/pub/bdr/Rconfig/r-devel-linux-x86_64-fedora-clang) machine in order to try and re-produce R package bugs specific to that machine. Complications are that they use a non-standard version of Clang which, given Clang don't provide binaries for fedora, means we have to compile Clang from source.  Note that on a MacBook Pro 2016 this takes ~6 hours to build. 

