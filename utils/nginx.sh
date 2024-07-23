#!/bin/bash

_nginx_configure() {
  local project_name=$1
  local public_folder=$2

  _nginx_create_config_file "${project_name}" "${public_folder}"
}

_nginx_create_config_file() {
  local project_name=$1
  local public_folder=$2

  local nginx_config="/etc/nginx/conf.d/${project_name}.${projects_tld}.conf"
  local nginx_template="${TEMPLATES}/nginx.conf"

  if [[ -f "${nginx_config}" ]]; then
    _print_message "WARNING" "Nginx configuration file for ${BOLD}${project_name}${END_BOLD} already exists. Replacing configuration."
  fi

  _print_message "INFO" "Creating Nginx configuration file for ${BOLD}${project_name}${END_BOLD}..."
  if sudo bash -c "sed 's|PROJECT_NAME|${project_name}|g; s|PUBLIC_FOLDER|${public_folder}|g; s|PROJECTS_TLD|${projects_tld}|g' ${nginx_template} > ${nginx_config}"; then
    _print_message "SUCCESS" "Nginx configuration file for ${BOLD}${project_name}${END_BOLD} created at ${BOLD}${nginx_config}${END_BOLD}."
  else
    _print_message "ERROR" "Failed to create Nginx configuration file for ${BOLD}${project_name}${END_BOLD}."
    return 1
  fi
}