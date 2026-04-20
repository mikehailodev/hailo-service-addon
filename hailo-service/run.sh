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

# Verify HailoRT version match (kernel driver vs userspace library)
KERNEL_VERSION=""
LIB_VERSION=""
if [ -f /sys/module/hailo_pci/version ]; then
    KERNEL_VERSION=$(cat /sys/module/hailo_pci/version)
    echo "[diag] Kernel module (hailo_pci) version: ${KERNEL_VERSION}"
else
    echo "[warn] Cannot read /sys/module/hailo_pci/version — skipping version check"
fi

LIB_SO=$(ls /usr/lib/libhailort.so.*.*.* 2>/dev/null | head -1)
if [ -n "${LIB_SO}" ]; then
    LIB_VERSION=$(echo "${LIB_SO}" | grep -oP '\d+\.\d+\.\d+$')
    echo "[diag] Userspace library (libhailort) version: ${LIB_VERSION}"
else
    echo "[warn] Cannot find libhailort.so.x.y.z — skipping version check"
fi

if [ -n "${KERNEL_VERSION}" ] && [ -n "${LIB_VERSION}" ]; then
    if [ "${KERNEL_VERSION}" != "${LIB_VERSION}" ]; then
        echo "============================================"
        echo " ERROR: HailoRT version mismatch!"
        echo " Kernel driver (hailo_pci): v${KERNEL_VERSION}"
        echo " Userspace (libhailort):    v${LIB_VERSION}"
        echo ""
        echo " HailoRT requires an exact version match."
        echo " Ensure HAOS and this add-on use the same"
        echo " HailoRT version."
        echo "============================================"
        exit 1
    fi
    echo "[OK] HailoRT versions match: v${KERNEL_VERSION}"
fi

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
