ARG DIST=18
FROM ubuntu:${DIST}.04
ARG DIST
ARG GCC_VER=7

RUN [ "${DIST}" = "18" ] || { apt-get update && apt-get install -y --no-install-recommends \
    software-properties-common bzip2 && add-apt-repository ppa:ubuntu-toolchain-r/test ; }

RUN apt-get update && apt-get install -y --no-install-recommends wget ca-certificates g++-${GCC_VER}  \
    libunwind-dev libevent-dev ninja-build ccache cmake \
    git make autoconf curl unzip automake zlib1g-dev python2.7 python-setuptools zip

RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-${GCC_VER} 60 \
                        --slave /usr/bin/g++ g++ /usr/bin/g++-${GCC_VER} \


