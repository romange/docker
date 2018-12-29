#!/bin/bash
set -o xtrace

BOOST_VERSION=$1
BOOST_NAME=boost_${BOOST_VERSION}

wget -nv "https://dl.bintray.com/boostorg/release/$(echo ${BOOST_VERSION} | tr '_' '.')/source/${BOOST_NAME}.tar.bz2"
tar -xjf ${BOOST_NAME}.tar.bz2 && rm ${BOOST_NAME}.tar.bz2 && cd ${BOOST_NAME}

./bootstrap.sh --prefix=/opt/${BOOST_NAME} --without-libraries=graph_parallel,graph,wave,test,mpi,python
b2_args=(define=BOOST_COROUTINES_NO_DEPRECATION_WARNING=1 link=shared variant=release debug-symbols=off
             threading=multi --without-test --without-math --without-log --without-locale --without-wave
             --without-regex --without-python -j4)

./b2 "${b2_args[@]}" cxxflags='-std=c++14 -Wno-deprecated-declarations -fPIC -O3'
./b2 install "${b2_args[@]}" -d0
ln -s /opt/${BOOST_NAME}  /opt/boost

cd - && rm -rf ${BOOST_NAME}
