#!/bin/bash

# Generate seed data JSON for LastFast with dates relative to current date
#
# Usage: ./Scripts/generate_seed_data.sh [output_file]
#
# If no output file is specified, writes to LastFast/Resources/SeedData/five_day_history.json

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
DEFAULT_OUTPUT="$PROJECT_DIR/LastFast/Resources/SeedData/five_day_history.json"
OUTPUT_FILE="${1:-$DEFAULT_OUTPUT}"

# Get current date in ISO format
EXPORT_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Function to generate ISO date string
# Args: days_ago, hour, minute
iso_date() {
    local days_ago=$1
    local hour=$2
    local minute=$3
    date -u -v-${days_ago}d -v${hour}H -v${minute}M -v0S +"%Y-%m-%dT%H:%M:%SZ"
}

# Generate the 5 fasting sessions
# Format: start_days_ago, start_hour, start_min, end_days_ago, end_hour, end_min, goal_minutes, goal_met

# Day 1 (most recent): Started yesterday 7:30pm, ended today 11:00am (15.5h), goal 15h, MET
START_1=$(iso_date 1 19 30)
END_1=$(iso_date 0 11 0)

# Day 2: Started 2 days ago 8:00pm, ended yesterday 12:30pm (16.5h), goal 16h, MET
START_2=$(iso_date 2 20 0)
END_2=$(iso_date 1 12 30)

# Day 3: Started 3 days ago 7:00pm, ended 2 days ago 11:30am (16.5h), goal 16h, MET
START_3=$(iso_date 3 19 0)
END_3=$(iso_date 2 11 30)

# Day 4: Started 4 days ago 8:30pm, ended 3 days ago 10:30am (14h), goal 15h, NOT MET
START_4=$(iso_date 4 20 30)
END_4=$(iso_date 3 10 30)

# Day 5: Started 5 days ago 7:30pm, ended 4 days ago 12:00pm (16.5h), goal 16h, MET
START_5=$(iso_date 5 19 30)
END_5=$(iso_date 4 12 0)

# Generate JSON
cat > "$OUTPUT_FILE" << EOF
{
  "version": 1,
  "exportDate": "$EXPORT_DATE",
  "sessions": [
    {
      "id": "A1111111-1111-1111-1111-111111111111",
      "startTime": "$START_1",
      "endTime": "$END_1",
      "goalMinutes": 900,
      "goalCelebrationShown": true
    },
    {
      "id": "B2222222-2222-2222-2222-222222222222",
      "startTime": "$START_2",
      "endTime": "$END_2",
      "goalMinutes": 960,
      "goalCelebrationShown": true
    },
    {
      "id": "C3333333-3333-3333-3333-333333333333",
      "startTime": "$START_3",
      "endTime": "$END_3",
      "goalMinutes": 960,
      "goalCelebrationShown": true
    },
    {
      "id": "D4444444-4444-4444-4444-444444444444",
      "startTime": "$START_4",
      "endTime": "$END_4",
      "goalMinutes": 900,
      "goalCelebrationShown": false
    },
    {
      "id": "E5555555-5555-5555-5555-555555555555",
      "startTime": "$START_5",
      "endTime": "$END_5",
      "goalMinutes": 960,
      "goalCelebrationShown": true
    }
  ]
}
EOF

echo "Generated seed data: $OUTPUT_FILE"
echo ""
echo "Sessions:"
echo "  Day 1: $START_1 -> $END_1 (15.5h, goal 15h, met)"
echo "  Day 2: $START_2 -> $END_2 (16.5h, goal 16h, met)"
echo "  Day 3: $START_3 -> $END_3 (16.5h, goal 16h, met)"
echo "  Day 4: $START_4 -> $END_4 (14h, goal 15h, NOT met)"
echo "  Day 5: $START_5 -> $END_5 (16.5h, goal 16h, met)"
