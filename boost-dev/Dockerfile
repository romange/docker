ARG DIST=18
FROM romange/ugcc:${DIST} as booster
ARG BOOST_VERSION=1_68_0
ARG DIST

RUN echo "Building Boost ${BOOST_VERSION} on Ubuntu $DIST"

WORKDIR /tmp
COPY install_boost.sh /tmp/
RUN ./install_boost.sh ${BOOST_VERSION}
