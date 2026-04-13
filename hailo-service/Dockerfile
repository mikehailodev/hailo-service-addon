ARG BUILD_FROM=ghcr.io/home-assistant/aarch64-base-debian:bookworm
FROM ${BUILD_FROM}

ENV DEBIAN_FRONTEND=noninteractive

# Extract HailoRT binaries from .deb without running postinst (needs systemctl)
COPY hailort_4.23.0_arm64.deb /tmp/hailort.deb
RUN dpkg-deb -x /tmp/hailort.deb / \
    && rm -f /tmp/hailort.deb \
    && ldconfig

COPY run.sh /run.sh
RUN chmod a+x /run.sh

LABEL \
    io.hass.version="4.23.0" \
    io.hass.type="addon" \
    io.hass.arch="aarch64|amd64"

CMD ["/run.sh"]
