#!/bin/bash

RELEASE_URL="https://github.com/rodrigomantoan/devset/releases/latest/download/devset.tar.gz"

INSTALL_DIR="/usr/local/devset"
SYMLINK_PATH="/usr/local/bin/devset"

if [ -d "$INSTALL_DIR" ]; then
  echo "The installation directory '$INSTALL_DIR' already exists."
  echo "Do you want to remove it and continue with the installation? [y/N]"
  read -r response
  response=${response:-N}
  if [[ "$response" =~ ^[Yy]$ ]]; then
    sudo rm -rf "$INSTALL_DIR"
    sudo mkdir -p "$INSTALL_DIR"
  else
    echo "Installation aborted."
    exit 1
  fi
else
  sudo mkdir -p "$INSTALL_DIR"
fi

echo "Downloading devset..."
sudo curl -L -o "$INSTALL_DIR/devset.tar.gz" "$RELEASE_URL"

echo "Extracting devset..."
sudo tar -xzvf "$INSTALL_DIR/devset.tar.gz" -C "$INSTALL_DIR"

sudo chmod +x "$INSTALL_DIR/devset.sh"
sudo chmod +x "$INSTALL_DIR/commands/"*.sh
sudo chmod +x "$INSTALL_DIR/utils/"*.sh

if [ -L "$SYMLINK_PATH" ]; then
  sudo rm "$SYMLINK_PATH"
fi

sudo ln -s "$INSTALL_DIR/devset.sh" "$SYMLINK_PATH"

sudo rm "$INSTALL_DIR/devset.tar.gz"

echo "devset installed successfully!"
echo "Please restart your terminal or open a new terminal session to use the 'devset' command."
echo "You can also run 'source ~/.bashrc' or 'source ~/.zshrc' to start using it immediately."