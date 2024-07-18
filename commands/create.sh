#!/bin/bash

create_project() {
  local project_name=$1
  local project_type=$2

  _print_message "DEBUG" "Creating project $BOLD${project_name^} (${project_type^})$RESET_BOLD on $ITALIC$projects_path/$project_name$RESET_ITALIC..."
}