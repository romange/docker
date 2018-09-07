ARG UBUNTU_VER=18.04
FROM ubuntu:${UBUNTU_VER} as ugcc7
ARG UBUNTU_VER

RUN [ "${UBUNTU_VER}" = "18.04" ] || { apt-get update && apt-get install -y --no-install-recommends \
    software-properties-common && add-apt-repository ppa:ubuntu-toolchain-r/test ; }

RUN apt-get update && apt-get install -y --no-install-recommends g++-7 wget ca-certificates && \
    update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-7 60 && \
    update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-7 60

FROM ugcc7 as booster
ARG BOOST_VERSION=1_68_0
ARG BOOST_NAME=boost_${BOOST_VERSION}

WORKDIR /tmp
RUN wget -nv "https://dl.bintray.com/boostorg/release/$(echo ${BOOST_VERSION} | tr '_' '.')/source/${BOOST_NAME}.tar.bz2"
RUN tar -xjf ${BOOST_NAME}.tar.bz2 && rm ${BOOST_NAME}.tar.bz2

WORKDIR /tmp/${BOOST_NAME}
RUN ./bootstrap.sh --prefix=/opt/boost --without-libraries=graph_parallel,graph,wave,test,mpi,python
RUN ./b2 --link=shared cxxflags="-std=c++14 -Wno-deprecated-declarations"  --variant=release --threading=multi \
         --without-test --without-python --without-mpi --without-graph --without-regex --without-wave --without-random --without-contract \
         --without-locale -j4
RUN ./b2 -d0 install
