#!/bin/bash

echo "********* Install Basics Server Environment ********"

export DEBIAN_FRONTEND=noninteractive

setup() {
  apt-get install -y --no-install-recommends $@
}

setup python3-setuptools libtool cmake golang

setup htop iotop sysstat ack-grep iftop vim vim-gui-common libhugetlbfs-bin

# To allow running perf as non-root
echo 'kernel.perf_event_paranoid = 1' >> /etc/sysctl.d/local.conf
echo 'kernel.kptr_restrict = 0' >> /etc/sysctl.d/local.conf

root_gist=https://gist.githubusercontent.com/romange/43114d544e2981cfe4a6/raw

cd /home/dev

wget -qnc $root_gist/.gitconfig
wget -qnc $root_gist/.bash_alias
wget -qnc $root_gist/.bashrc

BVER=1.73.0
BOOST=boost_${BVER//./_}   # replace all . with _

url="http://dl.bintray.com/boostorg/release/${BVER}/source/$BOOST.tar.bz2"
echo "Downloading from $url"

mkdir -p /tmp/boost && pushd /tmp/boost
wget -nv ${url} -O $BOOST.tar.bz2
tar -xjf $BOOST.tar.bz2

booststap_arg="--prefix=/opt/${BOOST} --without-libraries=graph_parallel,graph,wave,test,mpi,python"
cd $BOOST
boostrap_cmd=`readlink -f bootstrap.sh`

echo "Running ${boostrap_cmd} ${booststap_arg}"
${boostrap_cmd} ${booststap_arg} || { cat bootstrap.log; return 1; }
b2_args=(define=BOOST_COROUTINES_NO_DEPRECATION_WARNING=1 link=shared variant=release debug-symbols=on
          threading=multi --without-test --without-math --without-log --without-locale --without-wave
          --without-regex --without-python -j4)

echo "Building targets with ${b2_args[@]}"
./b2 "${b2_args[@]}" cxxflags='-std=c++14 -Wno-deprecated-declarations'
./b2 install "${b2_args[@]}" -d0