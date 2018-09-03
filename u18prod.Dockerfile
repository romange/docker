ARG UBUNTU_VER=18.04
FROM ubuntu:${UBUNTU_VER}

RUN apt-get update && apt-get install -y --no-install-recommends libevent-2.1-6 libevent-pthreads-2.1-6 libunwind8

COPY --from=romange/boost-builder /opt/boost/lib /usr/local/lib
WORKDIR /app
