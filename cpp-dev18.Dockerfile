FROM ubuntu:18.04

COPY --from=romange/boost-builder /opt/boost /usr/local
RUN apt-get update && apt-get install --no-install-recommends -y libunwind-dev libevent-dev ninja-build ccache cmake \
                     git make autoconf libtool curl unzip automake zlib1g-dev python2.7 python-setuptools zip
