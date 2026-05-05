ARG BUILD_FROM
FROM ${BUILD_FROM}

ARG TARGETARCH
ENV DEBIAN_FRONTEND=noninteractive

# Install HailoRT binaries from .deb (multi-arch: arm64 or amd64)
COPY hailort_artifacts/ /tmp/artifacts/
RUN set -eux \
    && DEB="/tmp/artifacts/hailort_4.23.0_${TARGETARCH}.deb" \
    && if [ ! -f "${DEB}" ]; then echo "ERROR: ${DEB} not found"; exit 1; fi \
    && mkdir /tmp/hailort \
    && dpkg-deb -x "${DEB}" /tmp/hailort \
    && cp /tmp/hailort/usr/lib/libhailort.so* /usr/lib/ \
    && cp /tmp/hailort/usr/local/bin/hailort_service /usr/local/bin/ \
    && cp /tmp/hailort/usr/bin/hailortcli /usr/bin/ \
    && rm -rf /tmp/hailort /tmp/artifacts \
    && ldconfig

COPY run.sh /run.sh
RUN chmod a+x /run.sh

CMD ["/run.sh"]
