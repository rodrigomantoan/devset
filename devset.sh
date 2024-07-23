#!/bin/bash

nginx_template='server {
    listen 80;
    server_name PROJECT_NAME.test;

    root PUBLIC_FOLDER;
    index index.php index.html index.htm;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php\$ {
        include fastcgi_params;
        fastcgi_pass unix:/run/php-fpm/www.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi.conf;
    }

    location ~ /\.ht {
        deny all;
    }
}'

### ./utils/common.sh ###
#!/bin/bash

BOLD="\033[1m"
ITALIC="\033[3m"

END_BOLD="\033[22m"
END_ITALIC="\033[23m"

GREEN="\033[0;92m"
RED="\033[0;91m"
YELLOW="\033[0;93m"
BLUE="\033[0;94m"
CYAN="\033[0;96m"
GRAY="\033[0;97m"
DEFAULT="\033[0m"

declare -A COLOR=(
    ["SUCCESS"]="$GREEN"
    ["ERROR"]="$RED"
    ["WARNING"]="$YELLOW"
    ["INFO"]="$BLUE"
    ["DEBUG"]="$GRAY"
    ["DEFAULT"]="$DEFAULT"
)

declare -A SYMBOL=(
    ["SUCCESS"]=" "  # Success (Nerd Font check)
    ["ERROR"]=" "  # Error (Nerd Font cross)
    ["WARNING"]=" "  # Warning (Nerd Font warning)
    ["INFO"]=" "  # Information (Nerd Font info)
    ["DEBUG"]=" "  # Debug (Nerd Font bug)
    ["DEFAULT"]=""  # Default
)

# Function to print formatted messages (based on type)
_print_message() {
    local type=${1:-"DEFAULT"}
    local message=$2

    # If only one argument is provided, treat it as message only
    if [ $# -eq 1 ]; then
        message=$1
        type="DEFAULT"
    fi

    echo -e "${COLOR[$type]}${SYMBOL[$type]}${message}${DEFAULT}"
}

_mkdir() {
  local path=$1
  local err_msg

  if [[ ! -d "$path" ]]; then
    _print_message "INFO" "Creating directory ${BOLD}$path${END_BOLD}..."
    mkdir -p "$path" 2>mkdir_error.log
    if [ $? -ne 0 ]; then
      err_msg=$(<mkdir_error.log)
      _print_message "ERROR" "Failed to create directory ${BOLD}$path${END_BOLD}. (${err_msg})"
      rm mkdir_error.log
      exit 1
    fi
    _print_message "SUCCESS" "Directory ${BOLD}$path${END_BOLD} created."
    rm mkdir_error.log
  else
    _print_message "WARNING" "Directory ${BOLD}$path${END_BOLD} already exists. Skipping folder creation."
  fi
}
### ./utils/helpers.sh ###
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
  local services=("$@") # Capture all arguments as an array
  local all_services=("nginx" "php-fpm")

  # If no arguments are passed, or "all" is passed, use all_services variable
  if [[ ${#services[@]} -eq 0 || " ${services[*]} " =~ " all " ]]; then
    services=("${all_services[@]}")
  fi

  _print_message "INFO" "Restarting services: ${BOLD}${services[*]}${END_BOLD}"

  local failed_services=()

  for service in "${services[@]}"; do
    if sudo systemctl restart "$service"; then succeeded_services+=("$service")
    else failed_services+=("$service")
    fi
  done

  if [[ ${#failed_services[@]} -eq 0 ]]; then _print_message "SUCCESS" "All services restarted successfully (${BOLD}${succeeded_services[*]}${END_BOLD})."
  else _print_message "ERROR" "Failed to restart services: ${BOLD}${failed_services[*]}${END_BOLD}"
  fi
}

### ./utils/nginx.sh ###
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
### ./commands/create.sh ###
#!/bin/bash

create_project() {
  local project_name=${1}
  local project_type=${2/--/}
  local project_folder=${projects_path}/${project_name}
  local public_folder="${project_folder}"

  _check_and_create_root_directory
  _check_project_folder_exists_and_empty
  _create_based_on_project_type

  _hosts_add_entry "${project_name}"
  _setup_permissions "${public_folder}"
  _nginx_configure "${project_name}" "${public_folder}"
  _restart_services "all"
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
    *) _create_blank_project ;;
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
  if [[ -z "${project_type}" ]]; then
    read -p "Does your project require a public folder? [Y/n]: " require_public
    require_public=${require_public:-y}
    require_public=$(echo "${require_public}" | tr '[:upper:]' '[:lower:]')

    if [[ "${require_public}" == "y" ]]; then
      public_folder="${project_folder}/public"
    else
      public_folder="${project_folder}"
    fi
    _mkdir "${public_folder}"
  else
    _print_message "ERROR" "Invalid project type. Please choose from --wordpress, --laravel, --statamic, or leave project type empty."
    exit 1
  fi
}
### ./commands/help.sh ###
#!/bin/bash

# Help function
help() {
  _print_message "${BLUE}${BOLD}Usage:${DEFAULT}"
  _print_message "  devset command [options]"

  _print_message "${BLUE}${BOLD}\nOptions:${DEFAULT}"
  _print_message "${GREEN}  -h, --help          ${DEFAULT}Display help message"
  _print_message "${GREEN}  -v, --version       ${DEFAULT}Display application version"

  _print_message "\n\033[1;34mAvailable commands:\033[0m"
  _print_message "${GREEN}  help                ${DEFAULT}Display help message"
  _print_message "${GREEN}  version             ${DEFAULT}Display application version"
  _print_message "${GREEN}  new, add, create    ${DEFAULT}Create a new project (automated process for Laravel, WordPress, and Statamic)"
  _print_message "${GREEN}  remove              ${DEFAULT}Remove an existing project"
}
### ./commands/install.sh ###

### ./commands/remove.sh ###
#!/bin/bash

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
### ./commands/uninstall.sh ###

### ./devset-dev.sh ###
#!/bin/bash

SCRIPT_VERSION="0.10.0" # Script version

projects_path="$HOME/Sites" # Projects path
projects_tld="test" # Projects TLD

# Main script logic
case "$1" in
  help|-h|--help)
    help
    ;;
  version|-v|--version)
    _print_message "INFO" "devset $SCRIPT_VERSION"
    ;;
  new|add|create|-n|--new|-a|--add)
    create_project "$2" "$3"
    ;;
  remove|-rm|--remove)
    remove_project "$2"
    ;;
  *)
    _print_message "ERROR" "Unknown command: $1"
    help
    ;;
esac
