#!/bin/bash

# Install Flutter
git clone https://github.com/flutter/flutter.git -b stable --depth 1
export PATH="$PATH:$(pwd)/flutter/bin"

# Setup dependencies
flutter precache
flutter config --enable-web
flutter doctor