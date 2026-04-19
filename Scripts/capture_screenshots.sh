#!/bin/bash

# App Store Screenshot Capture Script for LastFast
# Runs screenshot tests on required simulator sizes in both color modes
#
# Usage: ./Scripts/capture_screenshots.sh
#
# Output: Screenshots saved to Screenshots/<timestamp>/

set -o pipefail  # Exit on pipe failures but continue on test failures

# Configuration
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_DIR="${PROJECT_DIR}/Screenshots/${TIMESTAMP}"
SCHEME="LastFast"

# Required simulators (iOS 17+ App Store requirements)
declare -a SIMULATORS=(
    "iPhone 16 Pro Max"    # 6.9" (1320x2868)
    "iPhone 16 Plus"       # 6.7" (1290x2796)
)

# Color modes
declare -a COLOR_MODES=(
    "light"
    "dark"
)

# Create output directory
mkdir -p "$OUTPUT_DIR"

echo "========================================"
echo "  LastFast Screenshot Capture"
echo "========================================"
echo ""
echo "Output directory: $OUTPUT_DIR"
echo "Simulators: ${SIMULATORS[*]}"
echo "Color modes: ${COLOR_MODES[*]}"
echo ""

# Function to get simulator ID by name
get_simulator_id() {
    local name="$1"
    xcrun simctl list devices available | grep "$name" | head -1 | sed -E 's/.*\(([A-F0-9-]+)\).*/\1/'
}

# Function to run screenshot tests for a specific simulator and color mode
run_screenshots() {
    local simulator="$1"
    local color_mode="$2"
    local safe_sim_name="${simulator// /_}"

    # Get simulator ID
    local sim_id=$(get_simulator_id "$simulator")
    if [ -z "$sim_id" ]; then
        echo "  ERROR: Could not find simulator '$simulator'"
        return 1
    fi

    echo "----------------------------------------"
    echo "Capturing: $simulator ($color_mode mode)"
    echo "Simulator ID: $sim_id"
    echo "----------------------------------------"

    # Run UI tests - use xcodebuild with explicit test class
    # Skip the test plan by using -skip-testing for other test classes
    xcodebuild test \
        -project "$PROJECT_DIR/LastFast.xcodeproj" \
        -scheme "$SCHEME" \
        -destination "platform=iOS Simulator,id=$sim_id" \
        -skip-testing:LastFastUITests/FastingUITests \
        -skip-testing:LastFastUITests/OnboardingUITests \
        SCREENSHOT_OUTPUT_DIR="$OUTPUT_DIR" \
        SCREENSHOT_COLOR_MODE="$color_mode" \
        SCREENSHOT_DEVICE_NAME="$simulator" \
        2>&1 | while read -r line; do
            # Show only relevant output
            if [[ "$line" == *"Screenshot saved"* ]] || \
               [[ "$line" == *"Test Case"* ]] || \
               [[ "$line" == *"error:"* ]] || \
               [[ "$line" == *"** TEST"* ]]; then
                echo "  $line"
            fi
        done

    local exit_code=${PIPESTATUS[0]}

    if [ $exit_code -eq 0 ]; then
        echo "  Completed successfully"
    else
        echo "  WARNING: Some tests may have failed (exit code: $exit_code)"
    fi

    echo ""
}

# Boot simulators in parallel to save time
echo "Booting simulators..."
for sim in "${SIMULATORS[@]}"; do
    xcrun simctl boot "$sim" 2>/dev/null || true
done

# Wait for simulators to be ready
echo "Waiting for simulators to be ready..."
sleep 5

# Run tests for each combination
for sim in "${SIMULATORS[@]}"; do
    for mode in "${COLOR_MODES[@]}"; do
        run_screenshots "$sim" "$mode"
    done
done

# Shutdown simulators
echo "Shutting down simulators..."
for sim in "${SIMULATORS[@]}"; do
    xcrun simctl shutdown "$sim" 2>/dev/null || true
done

echo ""
echo "========================================"
echo "  Screenshot Capture Complete"
echo "========================================"
echo ""
echo "Output directory: $OUTPUT_DIR"
echo ""

# List captured screenshots
echo "Captured screenshots:"
find "$OUTPUT_DIR" -name "*.png" -type f 2>/dev/null | sort | while read -r file; do
    echo "  - $(basename "$file")"
done

# Count screenshots
SCREENSHOT_COUNT=$(find "$OUTPUT_DIR" -name "*.png" -type f 2>/dev/null | wc -l | tr -d ' ')
EXPECTED_COUNT=$((${#SIMULATORS[@]} * ${#COLOR_MODES[@]} * 4))

echo ""
echo "Summary:"
echo "  - Captured: $SCREENSHOT_COUNT screenshots"
echo "  - Expected: $EXPECTED_COUNT screenshots"

if [ "$SCREENSHOT_COUNT" -eq "$EXPECTED_COUNT" ]; then
    echo "  - Status: All screenshots captured successfully"
else
    echo "  - Status: Some screenshots may be missing"
fi

echo ""
echo "Open output folder:"
echo "  open \"$OUTPUT_DIR\""
