#!/bin/bash

# Path to the LÖVE executable
LOVE_EXEC="/Applications/love.app/Contents/MacOS/love"

# Check if LÖVE executable exists
if [ ! -f "$LOVE_EXEC" ]; then
    echo "Error: LÖVE executable not found at $LOVE_EXEC"
    exit 1
fi

# Launch the game
"$LOVE_EXEC" "$(pwd)"

echo "Game launched!" 