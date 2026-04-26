#!/bin/bash

# Reboot the currently running iOS Simulator with a specific locale
#
# Usage: ./Scripts/reboot_simulator_locale.sh <locale>
#
# Examples:
#   ./Scripts/reboot_simulator_locale.sh en_US    # US English
#   ./Scripts/reboot_simulator_locale.sh en_GB    # UK English
#   ./Scripts/reboot_simulator_locale.sh de_DE    # German
#   ./Scripts/reboot_simulator_locale.sh ja_JP    # Japanese
#   ./Scripts/reboot_simulator_locale.sh fr_FR    # French

set -e

LOCALE="$1"

if [ -z "$LOCALE" ]; then
    echo "Usage: $0 <locale>"
    echo ""
    echo "Examples:"
    echo "  $0 en_US    # US English"
    echo "  $0 en_GB    # UK English"
    echo "  $0 de_DE    # German"
    echo "  $0 ja_JP    # Japanese"
    exit 1
fi

# Extract language code from locale (e.g., "en" from "en_US")
LANGUAGE="${LOCALE%%_*}"
# Convert locale format for AppleLanguages (e.g., "en_US" -> "en-US")
LANGUAGE_TAG="${LOCALE/_/-}"

# Get the currently booted simulator
BOOTED_DEVICE=$(xcrun simctl list devices booted -j | grep -o '"udid" : "[^"]*"' | head -1 | cut -d'"' -f4)

if [ -z "$BOOTED_DEVICE" ]; then
    echo "Error: No simulator is currently running."
    echo "Please open a simulator first and try again."
    exit 1
fi

# Get device name for display
DEVICE_NAME=$(xcrun simctl list devices booted | grep -v "^--" | grep -v "^$" | head -1 | sed 's/ (Booted)//' | xargs)

echo "Rebooting simulator with locale: $LOCALE"
echo "Device: $DEVICE_NAME"
echo "Device ID: $BOOTED_DEVICE"
echo ""

# Set locale preferences while simulator is running
echo "Setting locale preferences..."
xcrun simctl spawn "$BOOTED_DEVICE" defaults write -g AppleLocale -string "$LOCALE"
xcrun simctl spawn "$BOOTED_DEVICE" defaults write -g AppleLanguages -array "$LANGUAGE_TAG" "$LANGUAGE"

# Shutdown the simulator
echo "Shutting down simulator..."
xcrun simctl shutdown "$BOOTED_DEVICE"

# Wait a moment for clean shutdown
sleep 2

# Boot the simulator again
echo "Booting simulator..."
xcrun simctl boot "$BOOTED_DEVICE"

# Open Simulator app to bring it to front
open -a Simulator

echo ""
echo "Done! Simulator rebooted with locale: $LOCALE"
