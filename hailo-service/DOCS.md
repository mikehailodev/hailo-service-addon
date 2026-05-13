# Hailo Service

HailoRT Multi-Process Service daemon for Hailo-8/8L.

## Overview

This add-on runs the `hailort_service` daemon, enabling multiple
Home Assistant add-ons to share a single Hailo AI accelerator
simultaneously.

## How it works

The Hailo multi-process service uses gRPC over a Unix domain socket
to multiplex access to the hardware. Client add-ons connect to:

```
/share/hailo/hailort_service.sock
```

## Requirements

- Hailo-8 or Hailo-8L hardware (e.g. Raspberry Pi AI Kit / AI HAT+)
- HAOS with `hailo_pci` kernel module v4.23.0

## Diagnostics

The add-on logs detailed diagnostics at startup:
- Device detection (`/dev/hailo0`)
- Kernel module version vs library version check
- Device identification (Hailo-8 vs Hailo-8L)
- Socket creation status

Check **Log** tab in the add-on page if something isn't working.

## Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| "HailoRT version mismatch" | HAOS kernel module version ≠ add-on version | Update HAOS or wait for matching add-on release |
| "/dev/hailo0 not found" | No Hailo hardware detected | Check PCIe connection, reboot |
| Socket not created | Service crashed | Check logs, ensure no other process owns /dev/hailo0 |
