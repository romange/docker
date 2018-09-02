ARG UBUNTU_VER=18.04
FROM ubuntu:${UBUNTU_VER}

ARG GCC_VER=7

RUN apt-get update && apt-get install -y --no-install-recommends wget ca-certificates g++-${GCC_VER}  \
    libunwind-dev libevent-dev ninja-build ccache cmake \
    git make autoconf libtool curl unzip automake zlib1g-dev python2.7 python-setuptools zip

RUN update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-${GCC_VER} 60 && \
    update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-${GCC_VER} 60

