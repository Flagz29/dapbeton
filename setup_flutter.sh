#!/bin/bash

# Install Flutter
echo "=== Installing Flutter ==="
git clone https://github.com/flutter/flutter.git -b stable --depth 1
export PATH="$PATH:$(pwd)/flutter/bin"

# Set up web
echo "=== Setting Up Web ==="
flutter precache
flutter config --enable-web

# Install dependencies
echo "=== Installing Dependencies ==="
flutter doctor -v
flutter clean
flutter pub get

# Fix permissions
echo "=== Fixing Permissions ==="
chmod -R 755 flutter