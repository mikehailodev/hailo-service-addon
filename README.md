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

## License

MIT
