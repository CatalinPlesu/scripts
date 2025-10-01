#!/bin/bash

# Get the current gamma value (this is the tricky part, as the tool might not report it directly.
# A simple solution is to keep track of the value in a file.)

GAMMA_FILE=~/.wlr_gamma_value
CURRENT_GAMMA=$(cat $GAMMA_FILE 2>/dev/null || echo 1.0)

INCREMENT=0.05

if [[ "$1" == "up" ]]; then
    NEW_GAMMA=$(echo "$CURRENT_GAMMA + $INCREMENT" | bc -l)
elif [[ "$1" == "down" ]]; then
    NEW_GAMMA=$(echo "$CURRENT_GAMMA - $INCREMENT" | bc -l)
else
    echo "Usage: $0 [up|down]"
    exit 1
fi

# Clamp the value to a reasonable range
if (( $(echo "$NEW_GAMMA > 2.0" | bc -l) )); then
    NEW_GAMMA=2.0
elif (( $(echo "$NEW_GAMMA < 0.2" | bc -l) )); then
    NEW_GAMMA=0.2
fi

# Apply the new gamma
wlr-gamma-control-cli -s $NEW_GAMMA
echo $NEW_GAMMA > $GAMMA_FILE
