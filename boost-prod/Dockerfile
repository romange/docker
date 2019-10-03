ARG DIST=18
ARG BOOST_VERSION=1_69_0
FROM romange/boost-dev:$DIST_$BOOST_VERSION as boost_libs

FROM ubuntu:${DIST}.04
ARG DIST
COPY install.sh /tmp/
RUN /tmp/install.sh ${DIST}

COPY --from=boost_libs /opt/boost_*/lib/*.so.* /usr/local/lib/
RUN ldconfig /usr/local/lib/
WORKDIR /app
