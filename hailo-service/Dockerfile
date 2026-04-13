ARG BUILD_FROM=ghcr.io/home-assistant/aarch64-base-debian:bookworm
FROM ${BUILD_FROM}

ENV DEBIAN_FRONTEND=noninteractive

# Install pre-built HailoRT from .deb (includes hailort_service, hailortcli, libhailort)
# Use dpkg directly to skip the interactive "accept service" prompt
COPY hailort_4.23.0_arm64.deb /tmp/hailort.deb
RUN apt-get update && apt-get install -y --no-install-recommends bash \
    && dpkg -i /tmp/hailort.deb || true \
    && apt-get install -yf --no-install-recommends \
    && rm -f /tmp/hailort.deb \
    && rm -rf /var/lib/apt/lists/* \
    && ldconfig

COPY run.sh /run.sh
RUN chmod a+x /run.sh

LABEL \
    io.hass.version="4.23.0" \
    io.hass.type="addon" \
    io.hass.arch="aarch64|amd64"

CMD ["/run.sh"]
