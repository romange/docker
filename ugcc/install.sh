#!/bin/bash
set -o xtrace

DIST=$1
GCC_VER=$2

setup() {
  apt-get install -y --no-install-recommends $@
}


if [ "${DIST}" = "16" ]; then
    echo 'deb http://ppa.launchpad.net/ubuntu-toolchain-r/test/ubuntu xenial main' >>  /etc/apt/sources.list.d/toolchain.list
    echo 'deb-src http://ppa.launchpad.net/ubuntu-toolchain-r/test/ubuntu xenial main' >>  /etc/apt/sources.list.d/toolchain.list
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 1E9377A2BA9EF27F
fi

apt-get update
setup libunwind8 binutils htop bzip2 wget ca-certificates g++-${GCC_VER} libunwind-dev  \
      ninja-build ccache libbz2-dev git make autoconf curl unzip automake \
      zlib1g-dev python3-setuptools zip libtool libssl-dev libxml2-dev

update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-${GCC_VER} 60 \
                    --slave /usr/bin/g++ g++ /usr/bin/g++-${GCC_VER}

wget https://github.com/Kitware/CMake/releases/download/v3.12.2/cmake-3.12.2-Linux-x86_64.sh
sh cmake-3.12.2-Linux-x86_64.sh --skip-license --prefix=/usr/local
