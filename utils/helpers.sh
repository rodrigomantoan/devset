#!/bin/bash

_hosts_add_entry() {
  if grep -q "${project_name}.${projects_tld}" /etc/hosts; then
    _print_message "WARNING" "/etc/hosts entry for ${BOLD}${project_name}.${projects_tld}${END_BOLD} already exists. Skipping this step."
  else
    _print_message "INFO" "Updating /etc/hosts file to add ${BOLD}${project_name}.${projects_tld}${END_BOLD}..."
    if echo "127.0.0.1  ${project_name}.${projects_tld}" | sudo tee -a /etc/hosts > /dev/null; then
      _print_message "SUCCESS" "/etc/hosts file updated with ${BOLD}${project_name}.${projects_tld}${END_BOLD}."
    else
      _print_message "ERROR" "Failed to update /etc/hosts file with ${BOLD}${project_name}.${projects_tld}${END_BOLD}."
      return 1
    fi
  fi
}