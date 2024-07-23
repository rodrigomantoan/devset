#!/bin/bash

# This script is used to set up the development environment for local projects

BASE_DIR=$(dirname "$0") # Script directory
SCRIPT_VERSION="0.9.0" # Script version
TEMPLATES="$BASE_DIR/templates" # Templates directory

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
source "$BASE_DIR/utils/helpers.sh"
source "$BASE_DIR/utils/nginx.sh"

# Main script logic
case "$1" in
  help|-h|--help)
    help
    ;;
  version|-v|--version)
    _print_message "INFO" "devset $SCRIPT_VERSION"
    ;;
  new|add|create|-n|--new|-a|--add)
    create_project "$2" "$3"
    ;;
  remove|-rm|--remove)
    remove_project "$2"
    ;;
  #install|-i|--install)
    #install
    #;;
  #uninstall|-u|--uninstall)
    #uninstall
    #;;
  *)
    _print_message "ERROR" "Unknown command: $1"
    help
    ;;
esac