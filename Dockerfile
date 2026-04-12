###############################################################################
# Stage 1: Build HailoRT + hailort_service from source
###############################################################################
FROM debian:bookworm AS builder

ARG HAILORT_VERSION=4.23.0

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    git \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN git clone --depth 1 --branch v${HAILORT_VERSION} \
    https://github.com/hailo-ai/hailort.git /src

WORKDIR /src

# Build with HAILO_BUILD_SERVICE to get the hailort_service binary.
# This also builds libhailort and hailortcli.
# NOTE: First build takes ~15-30 min (downloads + compiles protobuf/gRPC).
RUN cmake -S . -B build \
    -DCMAKE_BUILD_TYPE=Release \
    -DHAILO_BUILD_SERVICE=1 \
    && cmake --build build --config release -j"$(nproc)" --target install

###############################################################################
# Stage 2: Minimal runtime image
###############################################################################
FROM debian:bookworm-slim

# Runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    libstdc++6 \
    bash \
    && rm -rf /var/lib/apt/lists/*

# Copy built artifacts from builder
COPY --from=builder /usr/local/lib/libhailort.so* /usr/local/lib/
COPY --from=builder /usr/local/bin/hailort_service /usr/local/bin/
COPY --from=builder /usr/local/bin/hailortcli /usr/local/bin/
RUN ldconfig

COPY run.sh /run.sh
RUN chmod a+x /run.sh

LABEL \
    io.hass.version="4.23.0" \
    io.hass.type="addon" \
    io.hass.arch="aarch64|amd64"

CMD ["/run.sh"]
