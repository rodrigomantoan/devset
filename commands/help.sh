#!/bin/bash

# Help function
help() {
  echo -e "\033[1;34mUsage:\033[0m"
  echo -e "  devset [options] [--] <command>"
  echo -e "\n\033[1;34mOptions:\033[0m"
  echo -e "  -h, --help          Display this help message"
  echo -e "  -v, --version       Display this application version"
  echo -e "\n\033[1;34mAvailable commands:\033[0m"
  echo -e "  help                Display this help message"
}