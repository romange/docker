#!/bin/bash
set -o xtrace

DIST=$1

alias setup='apt-get install -y --no-install-recommends'

apt-get update && setup libunwind8 binutils htop

if [ "${DIST}" = "18" ]; then
  setup libevent-2.1-6 libevent-pthreads-2.1-6
else
  setup  libevent-2.0-5 libevent-pthreads-2.0-5 software-properties-common && add-apt-repository ppa:ubuntu-toolchain-r/test
  apt-get update
  setup gcc-7-base
fi
