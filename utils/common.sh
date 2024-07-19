#!/bin/bash

BOLD="\033[1m"
ITALIC="\033[3m"

END_BOLD="\033[22m"
END_ITALIC="\033[23m"

GREEN="\033[0;32m"
RED="\033[0;91m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
CYAN="\033[0;36m"
GRAY="\033[0;97m"
DEFAULT="\033[0m"

declare -A COLOR=(
    ["SUCCESS"]="$GREEN"
    ["ERROR"]="$RED"
    ["WARNING"]="$YELLOW"
    ["INFO"]="$BLUE"
    ["DEBUG"]="$GRAY"
    ["DEFAULT"]="$DEFAULT"
)

declare -A SYMBOL=(
    ["SUCCESS"]=" "  # Success (Nerd Font check)
    ["ERROR"]=" "  # Error (Nerd Font cross)
    ["WARNING"]=" "  # Warning (Nerd Font warning)
    ["INFO"]=" "  # Information (Nerd Font info)
    ["DEBUG"]=" "  # Debug (Nerd Font bug)
    ["DEFAULT"]=""  # Default
)

# Function to print formatted messages (based on type)
_print_message() {
    local type=${1:-"DEFAULT"}
    local message=$2

    # If only one argument is provided, treat it as message only
    if [ $# -eq 1 ]; then
        message=$1
        type="DEFAULT"
    fi

    echo -e "${COLOR[$type]}${SYMBOL[$type]}${message}${DEFAULT}"
}