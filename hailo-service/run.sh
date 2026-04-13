#!/usr/bin/env bash
set -e

echo "============================================"
echo " Hailo Service Add-on v4.23.0"
echo "============================================"

# ── Diagnostics ──
echo "[diag] Date: $(date)"
echo "[diag] Arch: $(uname -m)"
echo "[diag] Kernel: $(uname -r)"
echo "[diag] hailort_service: $(which hailort_service 2>&1 || echo 'NOT FOUND')"
echo "[diag] hailortcli: $(which hailortcli 2>&1 || echo 'NOT FOUND')"
echo "[diag] libhailort: $(ldconfig -p | grep hailort || echo 'NOT FOUND')"
echo "[diag] /dev/hailo*: $(ls -la /dev/hailo* 2>&1 || echo 'NONE')"
echo "[diag] /dev/shm: $(ls /dev/shm/ 2>&1 || echo 'NOT AVAILABLE')"

SOCK_DIR="/share/hailo"
mkdir -p "${SOCK_DIR}"
export HAILO_SOCK_PATH="${SOCK_DIR}"
echo "[diag] HAILO_SOCK_PATH=${HAILO_SOCK_PATH}"
echo "[diag] Socket dir contents: $(ls -la "${SOCK_DIR}" 2>&1)"

# Verify device
if [ ! -e /dev/hailo0 ]; then
    echo "ERROR: /dev/hailo0 not found."
    echo "Is a Hailo-8/8L device connected?"
    echo "[diag] All devices: $(ls /dev/ | head -30)"
    exit 1
fi

echo "Device /dev/hailo0 found."

# Identify device
echo "[diag] Running hailortcli fw-control identify..."
hailortcli fw-control identify 2>&1 || true

echo "Starting HailoRT service..."
echo "[diag] Exec: hailort_service"
exec hailort_service
