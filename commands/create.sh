#!/bin/bash

create_project() {
  local project_name=$1
  local project_type=${2/--/}
  local public_folder="$projects_path/$project_name"
  local folder_exists_empty=true

  _check_and_create_root_directory
  _check_project_folder_exists_and_empty
  _create_based_on_project_type

}

_check_and_create_root_directory() {
  # Check if the Sites directory exists and create if it doesn't
  if [[ ! -d "$projects_path" ]]; then
    _print_message "INFO" "Creating directory $projects_path..."
    mkdir -p "$projects_path"
    cd "$projects_path" || exit
    _print_message "SUCCESS" "Directory $projects_path created."
  fi
}

_check_project_folder_exists_and_empty() {
  if [[ -d "$projects_path/$project_name" ]] && [[ -z "$(ls -A "$projects_path/$project_name")" ]]; then
    _print_message "INFO" "Directory ${BOLD}$project_name${END_BOLD} exists and is empty. Proceeding with project setup."
    _print_message "INFO" "Removing empty directory $projects_path/$project_name to prevent conflicts..."
    rm -r "$projects_path/$project_name"
  elif [[ -d "$projects_path/$project_name" ]] && [[ ! -z "$(ls -A "$projects_path/$project_name")" ]]; then
    _print_message "ERROR" "Directory ${BOLD}$project_name${END_BOLD} exists and is not empty. Please choose another name."
    exit 1
  else
    _print_message "INFO" "No directory found for ${BOLD}$project_name${END_BOLD}. One will be created."
  fi
}

_create_based_on_project_type() {
  case "$project_type" in
    wordpress)
      _print_message "INFO" "Setting up a new ${BOLD}WordPress${END_BOLD} project..."
      mkdir -p "$projects_path/$project_name"
      curl -O https://wordpress.org/latest.tar.gz
      tar -xzvf latest.tar.gz -C "$projects_path/$project_name" --strip-components=1
      rm latest.tar.gz
      _print_message "SUCCESS" "${BOLD}WordPress${END_BOLD} project setup completed. Please create your database."
      ;;
    laravel|statamic)
      _print_message "INFO" "Setting up a new ${BOLD}${project_type^}${END_BOLD} project..."
      public_folder="$projects_path/$project_name/public"
      if composer create-project -q --prefer-dist $project_type/$project_type "$projects_path/$project_name"; then
        _print_message "SUCCESS" "${project_type^} project setup completed."
      else
        _print_message "ERROR" "Failed to set up ${project_type^} project."
      fi
      ;;
    *)
      if [[ -z "$project_type" ]]; then
        read -p "Does your project require a public folder? (Y/n): " require_public
        require_public=${require_public:-y}
        require_public=$(echo "$require_public" | tr '[:upper:]' '[:lower:]')
        _print_message "INFO" "Setting up a new ${BOLD}${project_name}${END_BOLD} project folder..."
        case "$require_public" in
          y)
            mkdir -p "$projects_path/$project_name/public"
            public_folder="$projects_path/$project_name/public"
            ;;
          *)
            mkdir -p "$projects_path/$project_name"
            public_folder="$projects_path/$project_name"
            ;;
        esac
        _print_message "SUCCESS" "${BOLD}${project_name}${END_BOLD} project folder setup completed."
      else
        _print_message "ERROR" "Invalid project type. Please choose from --wordpress, --laravel, --statamic, or leave project type empty."
        exit 1
      fi

  esac
}