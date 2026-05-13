ARG BUILD_FROM
FROM ${BUILD_FROM}

ARG TARGETARCH
ENV DEBIAN_FRONTEND=noninteractive

# ┌────────────────────────────────────────────────────────────────────────────┐
# │ HailoRT artifact installation                                              │
# │                                                                            │
# │ Currently: local .deb files from hailort_artifacts/                        │
# │ Future:    replace COPY+extract with curl from public URL                  │
# │            (see README.md "Switching to URL-based artifact downloads")     │
# └────────────────────────────────────────────────────────────────────────────┘
ARG HAILORT_VERSION=4.23.0
# TODO: When public URLs are available, uncomment the next lines and remove
#       the COPY line + hailort_artifacts/ directory:
# ARG HAILORT_DEB_URL_AMD64="https://REPLACE_ME/hailort_${HAILORT_VERSION}_amd64.deb"
# ARG HAILORT_DEB_URL_ARM64="https://REPLACE_ME/hailort_${HAILORT_VERSION}_arm64.deb"
# RUN apt-get update && apt-get install -y --no-install-recommends curl && rm -rf /var/lib/apt/lists/*
# RUN set -eux \
#     && if [ "${TARGETARCH}" = "amd64" ]; then URL="${HAILORT_DEB_URL_AMD64}"; \
#        else URL="${HAILORT_DEB_URL_ARM64}"; fi \
#     && curl -fsSL -o /tmp/hailort.deb "${URL}" \

# --- Local artifact install (remove this block when switching to URLs) ---
COPY hailort_artifacts/ /tmp/artifacts/
RUN set -eux \
    && DEB="/tmp/artifacts/hailort_${HAILORT_VERSION}_${TARGETARCH}.deb" \
    && if [ ! -f "${DEB}" ]; then echo "ERROR: ${DEB} not found"; exit 1; fi \
    && mkdir /tmp/hailort \
    && dpkg-deb -x "${DEB}" /tmp/hailort \
    && cp /tmp/hailort/usr/lib/libhailort.so* /usr/lib/ \
    && cp /tmp/hailort/usr/local/bin/hailort_service /usr/local/bin/ \
    && cp /tmp/hailort/usr/bin/hailortcli /usr/bin/ \
    && rm -rf /tmp/hailort /tmp/artifacts \
    && ldconfig
# --- End local artifact block ---

COPY run.sh /run.sh
RUN chmod a+x /run.sh

CMD ["/run.sh"]
