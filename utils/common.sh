#!/bin/bash

BOLD="\033[1m"
ITALIC="\033[3m"

RESET_BOLD="\033[22m"
RESET_ITALIC="\033[23m"

GREEN="\033[0;92m"
RED="\033[0;91m"
YELLOW="\033[0;93m"
BLUE="\033[0;94m"
CYAN="\033[0;96m"
GRAY="\033[0;97m"
DEFAULT="\033[0m"

declare -A COLOR=(
    ["SUCCESS"]="$GREEN"
    ["ERROR"]="$RED"
    ["WARN"]="$YELLOW"
    ["INFO"]="$BLUE"
    ["DEBUG"]="$GRAY"
    ["DEFAULT"]="$DEFAULT"
)

declare -A SYMBOL=(
    ["SUCCESS"]=""  # Success (Nerd Font check)
    ["ERROR"]=""  # Error (Nerd Font cross)
    ["WARN"]=""  # Warning (Nerd Font warning)
    ["INFO"]=""  # Information (Nerd Font info)
    ["DEBUG"]=""  # Debug (Nerd Font bug)
    ["DEFAULT"]=" "  # Default
)

# Function to print formatted messages (based on type)
__print_message() {
    local type=${1:-"DEFAULT"}
    local message=$2

    # If only one argument is provided, treat it as message only
    if [ $# -eq 1 ]; then
        message=$1
        type="DEFAULT"
    fi

    echo -e "${COLOR[$type]}${SYMBOL[$type]} ${message}${DEFAULT}"
}