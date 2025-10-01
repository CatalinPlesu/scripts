#!/bin/bash

# Define menu options using a single array with a separator '|'
options=(
    "1 Neovim|$HOME/.config/nvim|init.lua"
    "2 Tmux config|$HOME/.config/tmux|tmux.conf"
    "3.1 Qutebrowser config|$HOME/.config/qutebrowser|config.py"
    "3.2 Qutebrowser blocked|$HOME/.config/qutebrowser|blocked-hosts"
    "3.3 Qutebrowser search engines|$HOME/.config/qutebrowser/modules|search_engines.py"
    "3.4 Qutebrowser bindings|$HOME/.config/qutebrowser/modules|bindings.py"
    "4.1 shell aliases|$HOME/.config/shell|alias"
    "4.2 shell environment|$HOME/.config/shell|env"
    "4.4 zsh config|$HOME|.zshrc"
    "5.1 script window|$HOME/scripts|window_menu.sh"
    "5.2 script edit|$HOME/scripts|edit_config.sh"
    "6 autostart pods|$HOME/scripts|podman-compose-autostart"
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
    nvim "${option_details[2]}"
else
    echo "Invalid option"
fi
