#!/bin/bash

# Help function
help() {
  _print_message "${BLUE}${BOLD}Usage:${DEFAULT}"
  _print_message "  devset command [options]"

  _print_message "${BLUE}${BOLD}\nOptions:${DEFAULT}"
  _print_message "${GREEN}  -h, --help          ${DEFAULT}Display help message"
  _print_message "${GREEN}  -v, --version       ${DEFAULT}Display application version"

  _print_message "\n\033[1;34mAvailable commands:\033[0m"
  _print_message "${GREEN}  help                ${DEFAULT}Display help message"
  _print_message "${GREEN}  version             ${DEFAULT}Display application version"
  _print_message "${GREEN}  new, add, create    ${DEFAULT}Create a new project (automated process for Laravel, WordPress, and Statamic)"
}