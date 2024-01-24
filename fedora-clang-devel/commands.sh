

################
#
#  Local Machine
#


# Build the docker image
# Add `--no-cache` to force build from scratch

docker build --target base -t fedora-clang-devel:base .
docker build --target core -t fedora-clang-devel:core .
docker build --target extended -t fedora-clang-devel:extended .


################
#
#  Publish Image
#

docker tag fedora-clang-devel:extended gowerc1/fedora-clang-devel:clang18




################
#
#  Testing package within container
#

# Launch a detached container so VScode can attach itself
docker run --rm -dt fedora-clang-devel:extended bash 

# Or run interactive container and submit commands via terminal
docker run --rm -it fedora-clang-devel:extended bash

##### All following commands are to be run from within the container

mkdir /app
cd /app

# Clone repo
git clone https://github.com/insightsengineering/rbmi.git

cd rbmi

# Build and test
R CMD build .
R CMD check *.tar.gz


# Both with no vignettes
rm -rf mmrm.Rcheck/ mmrm_0.3.8.tar.gz
R CMD build --no-build-vignettes .; R CMD check --no-vignettes *.tar.gz
