#!/bin/bash

SCRIPT_VERSION="0.11.0" # Script version

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
  install|-i|--install)
    install_environment
    ;;
  new|add|create|-n|--new|-a|--add)
    _check_environment_silently
    create_project "$2" "$3"
    ;;
  remove|-rm|--remove)
    _check_environment
    remove_project "$2"
    ;;
  *)
    _print_message "ERROR" "Unknown command: $1"
    help
    ;;
esac