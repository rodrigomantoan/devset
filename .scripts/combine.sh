#!/bin/bash

# Define the output file
output_file="./devset.sh"

# Start with a shebang
echo '#!/bin/bash' > "$output_file"
echo '' >> "$output_file"

# Function to add file contents
add_file_contents() {
  local file=$1
  echo "### ${file} ###" >> "$output_file"
  cat "$file" >> "$output_file"
  echo '' >> "$output_file"
}

# Function to add template content as variables
add_template_content() {
  local template_file=$1
  local template_name=$(basename "$template_file" .conf)
  local template_content=$(<"$template_file")
  template_content=$(printf '%s\n' "$template_content" | sed -e 's/[$]/\\&/g')
  echo "${template_name}_template='${template_content}'" >> "$output_file"
  echo '' >> "$output_file"
}

# Add templates content to the output file
for template in ./templates/*.conf; do
  add_template_content "$template"
done

# Loop through the folders and add scripts
for folder in ./utils ./commands; do
  for script in "$folder"/*.sh; do
    add_file_contents "$script"
  done
done

# Add the main devset script
add_file_contents "./devset-dev.sh"

# Make the combined script executable
chmod +x "$output_file"

# Print success message
echo "Combined script created as $output_file"
