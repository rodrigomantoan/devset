#!/bin/bash

RELEASE_URL="https://github.com/rodrigomantoan/devset/releases/latest/download/devset.tar.gz"

INSTALL_DIR="/usr/local/bin/devset"

sudo mkdir -p "$INSTALL_DIR"

echo "Downloading devset..."
sudo curl -L -o "$INSTALL_DIR/devset.tar.gz" "$RELEASE_URL"

echo "Extracting devdet..."
sudo tar -xzvf "$INSTALL_DIR/devset.tar.gz" -C "$INSTALL_DIR"

sudo chmod +x "$INSTALL_DIR/devset.sh"
sudo chmod +x "$INSTALL_DIR/commands/"*.sh
sudo chmod +x "$INSTALL_DIR/utils/"*.sh

sudo ln -sf "$INSTALL_DIR/devset.sh" /usr/local/bin/devset

sudo rm "$INSTALL_DIR/devset.tar.gz"

echo "devset installed successfully!"
echo "Please restart your terminal or open a new terminal session to use the 'devset' command."
