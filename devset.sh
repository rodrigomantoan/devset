#!/bin/bash

# This script is used to set up the development environment for local projects

BASE_DIR=$(dirname "$0") # Script directory
SCRIPT_VERSION="0.1" # Script version

projects_path="$HOME/Sites" # Projects path
projects_tld="test" # Projects TLD

# Source command functions
source "$BASE_DIR/commands/help.sh"
source "$BASE_DIR/commands/create.sh"
source "$BASE_DIR/commands/remove.sh"
source "$BASE_DIR/commands/install.sh"
source "$BASE_DIR/commands/uninstall.sh"

# Source utility functions
source "$BASE_DIR/utils/common.sh"

# Main script logic
case "$1" in
  help|-h|--help)
    help
    ;;
  version|-v|--version)
    _print_message "INFO" "DevSet $SCRIPT_VERSION"
    ;;
  new|add|-n|--new|-a|--add)
    create_project "$2" "$3"
    ;;
  remove|-rm|--remove)
    # Placeholder for remove project
    echo "Remove project placeholder"
    ;;
  install|-i|--install)
    # Placeholder for install environment
    echo "Install environment placeholder"
    ;;
  uninstall|-u|--uninstall)
    # Placeholder for uninstall environment
    echo "Uninstall environment placeholder"
    ;;
  *)
    echo -e "\033[1;31mError:\033[0m Unknown command: $1"
    # Placeholder for help function
    echo "Help function placeholder"
    ;;
esac