FROM romange/ubuntu-gcc

COPY --from=romange/boost-builder /opt/boost /usr/local
RUN apt-get install -y  --no-install-recommends libbz2-dev
