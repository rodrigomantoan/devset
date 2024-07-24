#!/bin/bash

dependencies_checked=false
dependencies_installed=false
installed_dependencies=()

install_environment() {
  if [[ "${dependencies_installed}" = true ]]; then
    _print_message "INFO" "All dependencies are already installed in your system."
  else
    _print_message "INFO" "Starting installation of environment dependencies..."
    _check_dependencies true
    _php_fpm_setup
  fi
}

_check_environment_silently() {
  if [[ "${dependencies_installed}" = false && "${dependencies_checked}" = false ]]; then
    _check_dependencies false
  fi
}

_check_dependencies() {
  local show_messages=${1:-true}

  if [[ "${dependencies_checked}" = true ]]; then
    return
  fi

  local dependencies=("php" "composer" "nginx")
  local missing_dependencies=()

  for dep in "${dependencies[@]}"; do
    if ! command -v "${dep}" &> /dev/null; then
      missing_dependencies+=("${dep}")
    fi
  done

  if [[ ${#missing_dependencies[@]} -eq 0 ]]; then
    dependencies_checked=true
    dependencies_installed=true
    [[ "${show_messages}" = true ]] && _print_message "SUCCESS" "All dependencies are already installed."
  else
    read -p "$(_print_message "WARNING" "There are missing dependencies ${BOLD}(${missing_dependencies[*]})${END_BOLD}.${DEFAULT} Do you want to install them? [Y/n]: ")" install_choice
    install_choice=${install_choice:-y}
    install_choice=$(echo "${install_choice}" | tr '[:upper:]' '[:lower:]')

    case "${install_choice}" in
      y) for dep in "${missing_dependencies[@]}"; do _dependency_install "${dep}"; done; _php_fpm_setup ;;
      *) _print_message "ERROR" "Dependencies installation aborted. Please manually install required dependencies ${BOLD}(${missing_dependencies[*]})${END_BOLD} and rerun the script."; exit 1 ;;
    esac
  fi
}

_dependency_install() {
  local dependency=$1

  IFS=';' read -r -a package_commands <<< "$(_detect_package_manager)"

  if [[ "${package_commands[0]}" == "unsupported" ]]; then
    _print_message "ERROR" "Unsupported package manager. Please install ${dependency} manually."
    return 1
  fi

  _print_message "INFO" "Installing ${dependency}..."
  sudo ${package_commands[0]} "${dependency}"
  _print_message "SUCCESS" "${dependency} installed successfully."

  installed_dependencies+=("${dependency}")
}
