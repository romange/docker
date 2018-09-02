FROM romange/ubuntu-gcc

COPY --from=romange/boost-builder /opt/boost /usr/local
