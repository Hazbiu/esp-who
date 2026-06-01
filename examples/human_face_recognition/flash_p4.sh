#!/usr/bin/env bash
set -e

PROJECT_DIR="$HOME/Programming/BA_Org/esp-who/examples/human_face_recognition"
ESP_WHO_DIR="$HOME/Programming/BA_Org/esp-who"
IDF_DIR="$HOME/.espressif/v5.5.4/esp-idf"
PORT="${1:-/dev/ttyACM0}"

cd "$PROJECT_DIR"

echo "=== Activate ESP-IDF ==="
. "$IDF_DIR/export.sh"

echo "=== Set ESP-WHO extra actions ==="
export IDF_EXTRA_ACTIONS_PATH="$ESP_WHO_DIR/tools/"

echo "=== Check board port ==="
ls /dev/ttyUSB* /dev/ttyACM* 2>/dev/null || true
echo "Using port: $PORT"

echo "=== Clean old build ==="
rm -rf build sdkconfig

echo "=== Configure for ESP32-P4 Function EV Board ==="
idf.py -DSDKCONFIG_DEFAULTS=sdkconfig.bsp.esp32_p4_function_ev_board set-target esp32p4

echo "=== Patch ESP32-P4 minimum chip revision to v1.3 ==="
# ESP-IDF encodes v1.3 as 103, v3.1 as 301.
# Your board reported ESP32-P4 revision v1.3, so we must not build bootloader for v3.1+ only.
if grep -q '^CONFIG_ESP_REV_MIN_FULL=' sdkconfig; then
    sed -i 's/^CONFIG_ESP_REV_MIN_FULL=.*/CONFIG_ESP_REV_MIN_FULL=103/' sdkconfig
else
    echo 'CONFIG_ESP_REV_MIN_FULL=103' >> sdkconfig
fi

# Try to disable any selected v3.1 min-revision option if present.
sed -i 's/^CONFIG_ESP32P4_REV_MIN_3_1=y/# CONFIG_ESP32P4_REV_MIN_3_1 is not set/' sdkconfig 2>/dev/null || true
sed -i 's/^CONFIG_ESP32P4_REV_MIN_3_0=y/# CONFIG_ESP32P4_REV_MIN_3_0 is not set/' sdkconfig 2>/dev/null || true

echo "Current revision config:"
grep -E 'ESP.*REV.*MIN|ESP_REV_MIN_FULL' sdkconfig || true

echo "=== Build ==="
idf.py build

echo "=== Flash normally, without --force ==="
idf.py -p "$PORT" flash

echo "=== Monitor ==="
echo "Exit monitor with: Ctrl + ]"
idf.py -p "$PORT" monitor
