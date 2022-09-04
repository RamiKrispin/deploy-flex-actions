#!/bin/bash

# Installing Quarto
QUARTO_VERSION=$1
TEMP_QUARTO="$(mktemp)" &&
wget -O "$TEMP_QUARTO" https://github.com/quarto-dev/quarto-cli/releases/download/v$QUARTO_VERSION/quarto-${QUARTO_VERSION}-linux-amd64.deb &&
sudo dpkg -i "$TEMP_QUARTO"
rm -f "$TEMP_QUARTO"