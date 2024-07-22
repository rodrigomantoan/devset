#!/bin/bash

create_project() {
  local project_name=${1}
  local project_type=${2/--/}
  local project_folder=${projects_path}/${project_name}
  local public_folder="${project_folder}"

  _check_and_create_root_directory
  _check_project_folder_exists_and_empty
  _create_based_on_project_type

}

_check_and_create_root_directory() {
  # Check if the Sites directory exists and create if it doesn't
  if [[ ! -d "${projects_path}" ]]; then
    _mkdir "${projects_path}"
    cd "${projects_path}" || exit
  fi
}

_check_project_folder_exists_and_empty() {
  if [[ -d "${project_folder}" ]] && [[ -z "$(ls -A "${project_folder}")" ]]; then
    _print_message "INFO" "Directory ${BOLD}${project_name}${END_BOLD} exists and is empty. Proceeding with project setup."
    _print_message "INFO" "Removing empty directory ${BOLD}${project_folder}${END_BOLD} to prevent conflicts..."
    rm -r "${project_folder}"
  elif [[ -d "${project_folder}" ]] && [[ ! -z "$(ls -A "${project_folder}")" ]]; then
    _print_message "ERROR" "Directory ${BOLD}${project_name}${END_BOLD} exists and is not empty. Please choose another name for the project."
    exit 1
  else
    _print_message "INFO" "No directory found for ${BOLD}${project_name}${END_BOLD}. One will be created."
  fi
}

_create_based_on_project_type() {
  case "${project_type}" in
    wordpress) _create_wordpress_project ;;
    laravel|statamic) _create_composer_project ;;
    *)
      if [[ -z "${project_type}" ]]; then
        _create_blank_project
      else
        _print_message "ERROR" "Invalid project type. Please choose from --wordpress, --laravel, --statamic, or leave project type empty."
        exit 1
      fi

  esac
}

_create_wordpress_project() {
  _print_message "INFO" "Setting up a new ${BOLD}WordPress${END_BOLD} project..."

  _mkdir "${project_folder}"

  curl -O https://wordpress.org/latest.tar.gz
  tar -xzvf latest.tar.gz -C "${project_folder}" --strip-components=1
  rm latest.tar.gz

  _print_message "SUCCESS" "${BOLD}WordPress${END_BOLD} project setup completed. Please create your database."
}

_create_composer_project() {
  public_folder="${project_folder}/public"

  if composer create-project --prefer-dist ${project_type}/${project_type} "${project_folder}"; then
    _print_message "SUCCESS" "${project_type^} project setup completed."
  else
    _print_message "ERROR" "Failed to set up ${project_type^} project."
  fi
}

_create_blank_project() {
  read -p "Does your project require a public folder? (Y/n): " require_public
  require_public=${require_public:-y}
  require_public=$(echo "$require_public" | tr '[:upper:]' '[:lower:]')

  public_folder="$project_base_path${require_public:+/public}"
  _mkdir "${public_folder}"
}