#!/bin/bash

_nginx_configure() {
  local project_name=$1
  local public_folder=$2

  _nginx_create_config "${project_name}" "${public_folder}"
}

_nginx_create_config() {
  local project_name=$1
  local public_folder=$2

  local nginx_config="/etc/nginx/conf.d/${project_name}.${projects_tld}.conf"

  if [[ -f "${nginx_config}" ]]; then
    _print_message "WARNING" "Nginx configuration file for ${BOLD}${project_name}${END_BOLD} already exists. Replacing configuration."
  fi

  _print_message "INFO" "Creating Nginx configuration file for ${BOLD}${project_name}${END_BOLD}..."
  if sudo bash -c "sed 's|PROJECT_NAME|${project_name}|g; s|PUBLIC_FOLDER|${public_folder}|g; s|PROJECTS_TLD|${projects_tld}|g' <<< \"${nginx_template}\" > ${nginx_config}"; then
    _print_message "SUCCESS" "Nginx configuration file for ${BOLD}${project_name}${END_BOLD} created at ${BOLD}${nginx_config}${END_BOLD}."
  else
    _print_message "ERROR" "Failed to create Nginx configuration file for ${BOLD}${project_name}${END_BOLD}."
    return 1
  fi
}

_nginx_remove_config() {
  local project_name=$1
  local nginx_conf="/etc/nginx/conf.d/${project_name}.${projects_tld}.conf"

  if [[ -f "${nginx_conf}" ]]; then
    _print_message "INFO" "Removing Nginx configuration for ${BOLD}${project_name}${END_BOLD}..."

    if sudo rm "${nginx_conf}"; then
      _print_message "SUCCESS" "Nginx configuration for ${BOLD}${project_name}${END_BOLD} removed."
    else
      _print_message "ERROR" "Failed to remove Nginx configuration for ${BOLD}${project_name}${END_BOLD}."
    fi
  else
    _print_message "WARNING" "Nginx configuration for ${BOLD}${project_name}${END_BOLD} does not exist."
  fi
}