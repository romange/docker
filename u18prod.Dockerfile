ARG DIST=18
FROM romange/boost-builder:$DIST as boost_libs

FROM ubuntu:${DIST}.04
ARG DIST
RUN apt-get update && apt-get install -y libunwind8 && \
    { if [ "${DIST}" = "18" ] ; then apt-get install -y --no-install-recommends libevent-2.1-6 libevent-pthreads-2.1-6 ; \
      else apt-get install -y --no-install-recommends libevent-2.0-5 libevent-pthreads-2.0-5; fi; }

COPY --from=boost_libs /opt/boost/lib /usr/local/lib
WORKDIR /app
