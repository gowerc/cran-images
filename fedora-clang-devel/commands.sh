

################
#
#  Local Machine
#


# Build the docker image
docker build . --tag fedora-clang-devel:clang18 --no-cache


# Launch a detached container so VScode can attach itself
docker run --rm -dt fedora-clang-devel:clang18 bash



#############
#
#  In container
#


# Clone repo
git clone https://github.com/insightsengineering/rbmi.git

cd rbmi

# Build and test
R CMD build .
R CMD check *.tar.gz


# Both with no vignettes
rm -rf mmrm.Rcheck/ mmrm_0.3.8.tar.gz
R CMD build --no-build-vignettes .; R CMD check --no-vignettes *.tar.gz
