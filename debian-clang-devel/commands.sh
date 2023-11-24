


################
#
#  Local Machine
#


# Build the docker image
docker build . --tag debian-clang-devel:latest --no-cache


# Launch a detached container so VScode can attach itself
docker run --rm -dt debian-clang-devel:latest bash



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


