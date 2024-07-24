remove_project() {
  local project_name=$1
  local project_path=${projects_path}/${project_name}
  local nginx_conf="/etc/nginx/conf.d/${project_name}.${projects_tld}.conf"


  if [[ -z "$project_name" ]]; then
    _print_message "ERROR" "Project name is required."
    return 1
  fi

  if [[ -d "${project_path}"  ]] || [[ -f "${nginx_conf}" ]] || grep -q "${project_name}.${projects_tld}" /etc/hosts; then
    read -p "Are you sure you want to remove ${project_name}'s configurations? [Y/n]: " answer
      answer=${answer:-y}
      answer=$(echo "${answer}" | tr '[:upper:]' '[:lower:]')

      case "$answer" in
        y|yes) _remove_project_config "${project_name}" "${project_path}" ;;
        *) _print_message "INFO" "Project configuration removal aborted." ;;
      esac
  else
    _print_message "WARNING" "There's configuration or folder setup for ${BOLD}${project_name}${END_BOLD}."
  fi
}

_remove_project_config() {
  local project_name=$1
  local project_path=$2

  _nginx_remove_config "${project_name}"
  _hosts_remove_entry "${project_name}"

  read -p "$(_print_message "INFO" "All configuration were removed. ${RED}${BOLD}Do you want to delete project files?${DEFAULT} [y/N]:")" remove_folder
  remove_folder=${remove_folder:-n}
  remove_folder=$(echo "${remove_folder}" | tr '[:upper:]' '[:lower:]')
  case "$remove_folder" in
    y|yes) _remove_folder "${project_name}" "${project_path}" ;;
    *) _print_message "INFO" "Project files won't be deleted." ;;
  esac

}

_remove_folder() {
  local project_name=$1
  local project_path=$2

  if [[ -d "${project_path}" ]]; then
    _print_message "INFO" "Deleting project folder for ${BOLD}${project_name}${END_BOLD}..."
    if rm -r "${project_path}"; then
      _print_message "SUCCESS" "Project folder for ${BOLD}${project_name}${END_BOLD} removed."
    else
      _print_message "ERROR" "Failed to remove project folder for ${BOLD}${project_name}${END_BOLD}."
    fi
  else
    _print_message "WARNING" "Project folder for ${BOLD}${project_name}${END_BOLD} does not exist."
  fi
}
