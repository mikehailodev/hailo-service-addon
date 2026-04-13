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
export HAILORT_SERVICE_ADDRESS="unix:${SOCK_DIR}/hailort_service.sock"
echo "[diag] HAILORT_SERVICE_ADDRESS=${HAILORT_SERVICE_ADDRESS}"
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
echo "[diag] hailort_service will fork to background (Type=forking)"

# hailort_service forks to background and writes PID to /run/hailo/hailort_service.pid
mkdir -p /run/hailo
hailort_service

# Wait for PID file
sleep 1
if [ -f /run/hailo/hailort_service.pid ]; then
    PID=$(cat /run/hailo/hailort_service.pid)
    echo "[diag] hailort_service started with PID ${PID}"
    echo "[diag] Socket dir: $(ls -la ${SOCK_DIR}/ 2>&1)"
    # Keep the container alive by waiting on the daemon process
    while kill -0 "${PID}" 2>/dev/null; do
        sleep 5
    done
    echo "ERROR: hailort_service (PID ${PID}) exited unexpectedly"
    exit 1
else
    echo "ERROR: PID file not found at /run/hailo/hailort_service.pid"
    echo "[diag] /run/hailo contents: $(ls -la /run/hailo/ 2>&1)"
    exit 1
fi
