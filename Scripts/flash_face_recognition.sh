#!/usr/bin/env bash

# Stop immediately if any command fails.
set -e

# ------------------------------------------------------------
# Script purpose
# ------------------------------------------------------------
# This script builds, flashes, and monitors the ESP-WHO
# human_face_recognition example for ESP32-P4.
#
# Expected script location:
#   ~/Programming/BA_Org/esp-who/Scripts/flash_face_recognition.sh
#
# Exit serial monitor with:
#   Ctrl + ]
# ------------------------------------------------------------

# Directory where this script is located.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ESP-WHO root directory.
# From:
#   esp-who/Scripts
# To:
#   esp-who
ESP_WHO_PATH="$(realpath "$SCRIPT_DIR/..")"

# ESP-IDF directory.
# From:
#   ~/Programming/BA_Org/esp-who/Scripts
# To:
#   ~/Documents/v5.5/esp-idf
IDF_PATH="$(realpath "$SCRIPT_DIR/../../../../Documents/v5.5/esp-idf")"

# ESP-WHO face recognition example directory.
PROJECT_DIR="$ESP_WHO_PATH/examples/human_face_recognition"

# ESP-WHO tools directory required by IDF_EXTRA_ACTIONS_PATH.
ESP_WHO_TOOLS="$ESP_WHO_PATH/tools"

# ESP32-P4 BSP config available in the human_face_recognition example.
BSP_CONFIG="sdkconfig.bsp.esp32_p4_function_ev_board"

# ESP-IDF target for ESP32-P4.
TARGET="esp32p4"

# Default serial port.
# You can override it:
#   ./flash_face_recognition.sh /dev/ttyUSB0
PORT="${1:-/dev/ttyACM0}"

# ------------------------------------------------------------
# Print configuration
# ------------------------------------------------------------

echo "Script dir:    $SCRIPT_DIR"
echo "ESP-WHO path:  $ESP_WHO_PATH"
echo "ESP-IDF path:  $IDF_PATH"
echo "Project dir:   $PROJECT_DIR"
echo "Tools path:    $ESP_WHO_TOOLS"
echo "BSP config:    $BSP_CONFIG"
echo "Target:        $TARGET"
echo "Port:          $PORT"
echo

# ------------------------------------------------------------
# Validate paths
# ------------------------------------------------------------

if [ ! -f "$IDF_PATH/export.sh" ]; then
    echo "ERROR: ESP-IDF export.sh not found:"
    echo "  $IDF_PATH/export.sh"
    exit 1
fi

if [ ! -d "$ESP_WHO_PATH" ]; then
    echo "ERROR: ESP-WHO directory not found:"
    echo "  $ESP_WHO_PATH"
    exit 1
fi

if [ ! -d "$ESP_WHO_TOOLS" ]; then
    echo "ERROR: ESP-WHO tools directory not found:"
    echo "  $ESP_WHO_TOOLS"
    exit 1
fi

if [ ! -d "$PROJECT_DIR" ]; then
    echo "ERROR: Face recognition project directory not found:"
    echo "  $PROJECT_DIR"
    exit 1
fi

if [ ! -f "$PROJECT_DIR/$BSP_CONFIG" ]; then
    echo "ERROR: BSP config not found:"
    echo "  $PROJECT_DIR/$BSP_CONFIG"
    echo
    echo "Available BSP configs:"
    find "$PROJECT_DIR" -maxdepth 1 -name "sdkconfig.bsp.*" -printf "  %f\n"
    exit 1
fi

if [ ! -e "$PORT" ]; then
    echo "WARNING: Serial port does not exist:"
    echo "  $PORT"
    echo "Connect the board or pass another port, for example:"
    echo "  ./flash_face_recognition.sh /dev/ttyUSB0"
    echo
fi

# ------------------------------------------------------------
# Load ESP-IDF and ESP-WHO environment
# ------------------------------------------------------------

# Load ESP-IDF environment.
# This enables idf.py, the compiler toolchain, Python environment, etc.
source "$IDF_PATH/export.sh"

# ESP-WHO examples require this environment variable.
# It lets idf.py find ESP-WHO's extra build actions.
export IDF_EXTRA_ACTIONS_PATH="$ESP_WHO_TOOLS"

echo "IDF_EXTRA_ACTIONS_PATH=$IDF_EXTRA_ACTIONS_PATH"
echo

# ------------------------------------------------------------
# Build, flash, and monitor
# ------------------------------------------------------------

# Go to the ESP-WHO face recognition example.
cd "$PROJECT_DIR"

# Remove old build output.
# If there is nothing to clean, continue.
idf.py fullclean || true

# Set target to ESP32-P4 and load the ESP32-P4 BSP defaults.
idf.py -DSDKCONFIG_DEFAULTS="$BSP_CONFIG" set-target "$TARGET"

# Build the firmware.
idf.py build

# Flash the firmware and open the serial monitor.
idf.py -p "$PORT" flash monitor
