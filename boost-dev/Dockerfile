ARG DIST=18
FROM romange/ugcc:${DIST} as booster
ARG BOOST_VERSION=1_68_0

WORKDIR /tmp
COPY install_boost.sh /tmp/
RUN ./install_boost.sh ${BOOST_VERSION}
