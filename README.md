# Hailo Service Add-on for Home Assistant

HailoRT Multi-Process Service daemon for Hailo-8/8L accelerators.
Enables multiple Home Assistant add-ons to share a single Hailo device
simultaneously via gRPC + shared memory.

## What it does

Runs the `hailort_service` daemon which:
- Owns exclusive access to `/dev/hailo0`
- Exposes a gRPC socket at `/share/hailo/hailort_service.sock`
- Allows multiple client add-ons (Frigate, custom apps) to run inference
  on the same Hailo device concurrently

## Requirements

- Home Assistant OS with Hailo-8 or Hailo-8L hardware
  (e.g. Raspberry Pi AI Kit, Raspberry Pi AI HAT+)
- HAOS kernel module `hailo_pci` version **4.23.0**
  (included in HAOS 15.x+)

## Installation

1. Add this repository to Home Assistant:
   **Settings → Add-ons → Add-on Store → ⋮ → Repositories**
   ```
   https://github.com/mikehailodev/hailo-service-addon
   ```
2. Install "Hailo Service"
3. Start the add-on
4. Check logs — you should see "HailoRT versions match" and a PID

## Configuration

No configuration needed. The add-on auto-detects the Hailo device
and starts the service.

## Client add-ons

Any add-on that wants to use the Hailo device via multi-process mode
needs:
- `host_ipc: true` in its `config.yaml`
- `map: share:rw` to access the socket
- Environment variable: `HAILORT_SERVICE_ADDRESS=unix:/share/hailo/hailort_service.sock`

## Architecture

```
┌─────────────────┐  ┌─────────────────┐
│ Frigate Add-on  │  │ Example Add-on  │
│ (client)        │  │ (client)        │
└────────┬────────┘  └────────┬────────┘
         │ gRPC (unix socket)  │
         └─────────┬───────────┘
                   ▼
    /share/hailo/hailort_service.sock
                   │
         ┌─────────┴──────────┐
         │ Hailo Service       │
         │ (hailort_service)   │
         │ owns /dev/hailo0    │
         └─────────────────────┘
```

## Supported architectures

- `aarch64` (Raspberry Pi 5, etc.)
- `amd64` (x86-64 systems with Hailo-8 PCIe)

## Version matching

HailoRT requires an **exact version match** between the kernel module
and the userspace library. This add-on ships HailoRT **4.23.0**.
If HAOS has a different kernel module version, the add-on will refuse
to start and log an error.

## Switching to URL-based artifact downloads

Currently, `.deb` files are committed in `hailo-service/hailort_artifacts/`.
When public download URLs become available:

1. Delete `hailo-service/hailort_artifacts/` directory
2. Edit `hailo-service/Dockerfile` — replace the `COPY` + extract block with:
   ```dockerfile
   ARG HAILORT_VERSION=4.23.0
   ARG HAILORT_DEB_URL_AMD64="https://example.com/hailort_${HAILORT_VERSION}_amd64.deb"
   ARG HAILORT_DEB_URL_ARM64="https://example.com/hailort_${HAILORT_VERSION}_arm64.deb"

   RUN set -eux \
       && if [ "${TARGETARCH}" = "amd64" ]; then URL="${HAILORT_DEB_URL_AMD64}"; \
          else URL="${HAILORT_DEB_URL_ARM64}"; fi \
       && curl -fsSL -o /tmp/hailort.deb "${URL}" \
       && mkdir /tmp/hailort \
       && dpkg-deb -x /tmp/hailort.deb /tmp/hailort \
       && cp /tmp/hailort/usr/lib/libhailort.so* /usr/lib/ \
       && cp /tmp/hailort/usr/local/bin/hailort_service /usr/local/bin/ \
       && cp /tmp/hailort/usr/bin/hailortcli /usr/bin/ \
       && rm -rf /tmp/hailort /tmp/hailort.deb \
       && ldconfig
   ```
3. Add `curl` to the base image (or use `wget`)
4. Remove `.deb` files from git history:
   ```bash
   git filter-repo --path hailo-service/hailort_artifacts/ --invert-paths
   git push --force
   ```

## License

MIT
