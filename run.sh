#!/usr/bin/env bash
set -e

SOCK_DIR="/share/hailo"
mkdir -p "${SOCK_DIR}"
export HAILO_SOCK_PATH="${SOCK_DIR}"

echo "============================================"
echo " Hailo Service Add-on v4.23.0"
echo "============================================"
echo "Socket dir: ${SOCK_DIR}"

# Verify device
if [ ! -e /dev/hailo0 ]; then
    echo "ERROR: /dev/hailo0 not found."
    echo "Is a Hailo-8/8L device connected?"
    exit 1
fi

echo "Device /dev/hailo0 found."

# Identify device
hailortcli fw-control identify 2>&1 || true

echo "Starting HailoRT service..."
exec hailort_service
