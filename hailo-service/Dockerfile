ARG BUILD_FROM=ghcr.io/home-assistant/aarch64-base-debian:bookworm
FROM ${BUILD_FROM}

ENV DEBIAN_FRONTEND=noninteractive

# Extract HailoRT binaries from .deb (extract to temp dir to avoid overwriting system files)
COPY hailort_4.23.0_arm64.deb /tmp/hailort.deb
RUN mkdir /tmp/hailort \
    && dpkg-deb -x /tmp/hailort.deb /tmp/hailort \
    && cp /tmp/hailort/usr/lib/libhailort.so* /usr/lib/ \
    && cp /tmp/hailort/usr/local/bin/hailort_service /usr/local/bin/ \
    && cp /tmp/hailort/usr/bin/hailortcli /usr/bin/ \
    && rm -rf /tmp/hailort /tmp/hailort.deb \
    && ldconfig

COPY run.sh /run.sh
RUN chmod a+x /run.sh

LABEL \
    io.hass.version="4.23.0" \
    io.hass.type="addon" \
    io.hass.arch="aarch64|amd64"

CMD ["/run.sh"]
