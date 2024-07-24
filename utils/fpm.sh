#!/bin/bash

_php_fpm_setup() {
  local user=$USER
  local fpm_conf="/etc/php-fpm.d/www.conf"
  local fpm_conf_backup="/etc/php-fpm.d/www.conf.bak"

  _print_message "INFO" "Setting up PHP-FPM configuration..."

  if [[ ! -f "$fpm_conf_backup" ]]; then
    sudo cp "$fpm_conf" "$fpm_conf_backup"
    _print_message "SUCCESS" "PHP-FPM configuration backup created at $fpm_conf_backup."
  else
    _print_message "INFO" "PHP-FPM configuration backup already exists."
  fi

  # Modify PHP-FPM configuration file
  sudo sed -i "s/^user = .*/user = $user/" "$fpm_conf"
  sudo sed -i "s/^group = .*/group = $user/" "$fpm_conf"
  sudo sed -i "s/;listen.owner = .*/listen.owner = nginx/" "$fpm_conf"
  sudo sed -i "s/;listen.group = .*/listen.group = nginx/" "$fpm_conf"
  sudo sed -i "s/;listen.mode = .*/listen.mode = 0660/" "$fpm_conf"

  _print_message "SUCCESS" "PHP-FPM configuration updated."
  _restart_services "all"
}

_php_fpm_restore() {
  local fpm_conf="/etc/php-fpm.d/www.conf"
  local fpm_conf_backup="/etc/php-fpm.d/www.conf.bak"

  if [[ -f "$fpm_conf_backup" ]]; then
    _print_message "INFO" "Restoring PHP-FPM configuration from backup..."
    sudo cp "$fpm_conf_backup" "$fpm_conf"
    _print_message "SUCCESS" "PHP-FPM configuration restored from $fpm_conf_backup."
    _restart_services "all"
  else
    _print_message "WARNING" "No PHP-FPM backup configuration found to restore."
  fi
}