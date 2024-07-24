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

_hosts_remove_entry() {
  if grep -q "${project_name}.${projects_tld}" /etc/hosts; then
    _print_message "INFO" "Removing hosts entry for ${BOLD}${project_name}${END_BOLD}..."

    if sudo sed -i "/${project_name}.${projects_tld}/d" /etc/hosts; then
      _print_message "SUCCESS" "Hosts entry for ${BOLD}${project_name}${END_BOLD} removed."
    else
      _print_message "ERROR" "Failed to remove hosts entry for ${BOLD}${project_name}${END_BOLD}."
    fi
  else
    _print_message "WARNING" "Hosts entry for ${BOLD}${project_name}${END_BOLD} does not exist."
  fi
}

_setup_permissions() {
  _print_message "INFO" "Setting permissions for ${BOLD}${public_folder}${END_BOLD}..."
  if sudo chown -R $USER:nginx ${public_folder} && sudo chmod -R 755 ${public_folder}; then
    _print_message "SUCCESS" "Permissions set for ${BOLD}${public_folder}${END_BOLD}."
  else
    _print_message "ERROR" "Failed to set permissions for ${BOLD}${public_folder}${END_BOLD}."
    return 1
  fi

  if command -v getenforce &>/dev/null && [[ "$(getenforce)" != "Disabled" ]]; then
    _print_message "INFO" "Setting SELinux context for ${BOLD}${public_folder}${END_BOLD}..."
    if sudo chcon -R -t httpd_sys_content_t "${public_folder}" && sudo chcon -R -t httpd_sys_rw_content_t "${public_folder}"; then
      _print_message "SUCCESS" "SELinux context set for ${BOLD}${public_folder}${END_BOLD}."
    else
      _print_message "ERROR" "Failed to set SELinux context for ${BOLD}${public_folder}${END_BOLD}."
      return 1
    fi
  fi
}

_restart_services() {
  local services=("$@")
  local all_services=("nginx" "php-fpm")

  if [[ ${#services[@]} -eq 0 || " ${services[*]} " =~ " all " ]]; then
    services=("${all_services[@]}")
  fi

  _print_message "INFO" "Restarting services (${BOLD}${services[*]}${END_BOLD})"

  local failed_services=()

  for service in "${services[@]}"; do
    if sudo systemctl restart "$service"; then succeeded_services+=("$service")
    else failed_services+=("$service")
    fi
  done

  if [[ ${#failed_services[@]} -eq 0 ]]; then _print_message "SUCCESS" "All services restarted successfully (${BOLD}${succeeded_services[*]}${END_BOLD})."
  else _print_message "ERROR" "Failed to restart services (${BOLD}${failed_services[*]}${END_BOLD})";
  fi
}

_detect_package_manager() {
  declare -A os_info
  os_info[/etc/debian_version]="apt update && apt install -y;apt remove -y"
  os_info[/etc/lsb-release]="apt update && apt install -y;apt remove -y"  # For Ubuntu and derivatives
  os_info[/etc/fedora-release]="dnf install -y;dnf remove -y"
  os_info[/etc/redhat-release]="yum install -y;yum remove -y"
  os_info[/etc/centos-release]="yum install -y;yum remove -y"
  os_info[/etc/arch-release]="pacman -Syu --noconfirm;pacman -Rns --noconfirm"
  os_info[/etc/gentoo-release]="emerge --ask;emerge --unmerge"
  os_info[/etc/SuSE-release]="zypper install -y;zypper remove -y"
  os_info[/etc/alpine-release]="apk add;apk del"

  for f in "${!os_info[@]}"; do
    if [[ -f $f ]]; then
      echo "${os_info[$f]}"
      return
    fi
  done

  echo "unsupported;unsupported"
}