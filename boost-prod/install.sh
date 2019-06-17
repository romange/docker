#!/bin/bash
set -o xtrace

DIST=$1

setup() {
  apt-get install -y --no-install-recommends $@
}


if [ "${DIST}" = "16" ]; then
    echo 'deb http://ppa.launchpad.net/ubuntu-toolchain-r/test/ubuntu xenial main' >>  /etc/apt/sources.list.d/toolchain.list
    echo 'deb-src http://ppa.launchpad.net/ubuntu-toolchain-r/test/ubuntu xenial main' >>  /etc/apt/sources.list.d/toolchain.list
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 1E9377A2BA9EF27F
fi

apt-get update && setup libunwind8 binutils htop

if [ "${DIST}" = "18" ]; then
  # setup libevent-2.1-6 libevent-pthreads-2.1-6
  echo pass
else
  # setup  libevent-2.0-5 libevent-pthreads-2.0-5
  apt-get upgrade -y libstdc++6
fi
