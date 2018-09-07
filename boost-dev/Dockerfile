ARG DIST=18
FROM romange/ugcc:${DIST} as booster
ARG BOOST_VERSION=1_68_0
ARG BOOST_NAME=boost_${BOOST_VERSION}

WORKDIR /tmp
COPY install_boost.sh /tmp/
RUN ./install_boost.sh
