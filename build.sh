#!/bin/bash
# Exit immediately if a command exits with a non-zero status
set -e

FLUTTER_VERSION="3.22.2"

echo "=== System Architecture ==="
uname -a

echo "=== Cloning Flutter SDK ($FLUTTER_VERSION) ==="
git clone --branch "$FLUTTER_VERSION" --depth 1 https://github.com/flutter/flutter.git
export PATH="$PATH:$(pwd)/flutter/bin"

echo "=== Verifying Flutter Installation ==="
flutter --version

echo "=== Initializing Flutter Web Platform ==="
cd frontend
flutter create --platforms=web .

echo "=== Fetching Flutter Dependencies ==="
flutter pub get

echo "=== Building Flutter Web App ==="
flutter build web --release --dart-define=BACKEND_URL=/api

echo "=== Build Completed Successfully ==="
