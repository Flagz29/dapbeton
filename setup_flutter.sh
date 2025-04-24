#!/bin/bash

# Install Flutter
echo "=== Installing Flutter ==="
git clone https://github.com/flutter/flutter.git -b stable --depth 1
export PATH="$PATH:$PWD/flutter/bin"

# Setup environment
echo "=== Setting Up Environment ==="
echo "export PATH=\"\$PATH:$PWD/flutter/bin\"" >> ~/.bashrc
source ~/.bashrc

# Verify installation
echo "=== Verifying Installation ==="
which flutter
flutter --version

# Build setup
echo "=== Configuring Build ==="
flutter config --no-analytics
flutter config --enable-web
flutter clean
flutter pub get

# Fix permissions
echo "=== Fixing Permissions ==="
chmod -R 755 flutter