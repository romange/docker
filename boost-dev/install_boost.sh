#!/bin/bash
set -o xtrace

BOOST_VERSION=$1
BOOST_NAME=boost_${BOOST_VERSION}

wget -nv "https://dl.bintray.com/boostorg/release/$(echo ${BOOST_VERSION} | tr '_' '.')/source/${BOOST_NAME}.tar.bz2"
tar -xjf ${BOOST_NAME}.tar.bz2 && rm ${BOOST_NAME}.tar.bz2 && cd ${BOOST_NAME}

./bootstrap.sh --prefix=/opt/boost --without-libraries=graph_parallel,graph,wave,test,mpi,python
./b2 --link=shared cxxflags="-std=c++14 -Wno-deprecated-declarations"  --variant=release --threading=multi \
         --without-test --without-python --without-mpi --without-graph --without-regex --without-wave --without-random --without-contract \
         --without-locale -j4
./b2 -d0 install
cd - && rm -rf ${BOOST_NAME}
