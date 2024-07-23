#!/bin/bash

SCRIPT_VERSION="0.10.0" # Script version

projects_path="$HOME/Sites" # Projects path
projects_tld="test" # Projects TLD

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
  *)
    _print_message "ERROR" "Unknown command: $1"
    help
    ;;
esac