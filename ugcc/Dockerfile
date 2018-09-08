ARG DIST=18
FROM ubuntu:${DIST}.04
ARG DIST
ARG GCC_VER=7

COPY install.sh /tmp/
RUN /tmp/install.sh ${DIST} ${GCC_VER}

ENV PATH /usr/lib/ccache:$PATH

