#!/bin/bash

# This script finds core files in the current directory that include timestamp (%t),
# and prints each filename with its timestamp converted to a human-readable format.

set -euo pipefail

shopt -s nullglob
 
FOUND=0

for f in core.*; do
    # Treat the part after the last '.' as the timestamp
    ts="${f##*.}"

    # Check if it is a number
    if [[ "$ts" =~ ^[0-9]+$ ]]; then
        # Convert epoch to human-readable time
        human_time="$(date -d "@$ts" '+%Y-%m-%d %H:%M:%S %Z' 2>/dev/null || echo 'Conversion failed')"

        printf "%-40s  %s\n" "$f" "$human_time"
        FOUND=1
    fi
done

if [ "$FOUND" -eq 0 ]; then
    echo "No core files with timestamp (%t) found in the current directory."
fi

