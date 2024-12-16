#!/bin/bash

# Define menu options using a single array with a separator '|'
options=(
    "1. Home|$HOME| "
    "2. Downloads|$HOME/Downloads| "
    "3. Config ||source $HOME/scripts/edit_config.sh"
)

# Extracting the first part of each string before the delimiter '|'
options_display=()
default_option_display=""
for opt in "${options[@]}"; do
    text=$(echo "$opt" | cut -d '|' -f 1)
    options_display+=("$text")
    if [ -z "$default_option_display" ]; then
        default_option_display="$text"
    fi
done

# Use fzf with the modified list to create an interactive menu
selected_option=$(printf "%s\n" "${options_display[@]}" | fzf --prompt="Select an option: " --select-1 --exit-0)

# Find the corresponding full option string
for opt in "${options[@]}"; do
    if [[ "$opt" == *"$selected_option"* ]]; then
        selected_option="$opt"
        break
    fi
done

# Check if user selected an option or used default
if [ -z "$selected_option" ]; then
    selected_option="$default_option"
fi

# Split the selected option using the separator '|'
IFS='|' read -r -a option_details <<< "$selected_option"

# Perform actions based on the selected option
if [ "${#option_details[@]}" -eq 3 ]; then
    cd "${option_details[1]}"
    if [ -n "${option_details[2]}" ]; then
        eval "${option_details[2]}"
    fi
else
    echo "Invalid option"
fi
