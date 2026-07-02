#!/bin/bash
# Exit immediately if a command exits with a non-zero status
set -e

FLUTTER_VERSION="3.22.2"

# Set HOME to current directory to guarantee write permissions for config/cache files
export HOME=$(pwd)

# Mark all directories as safe for git to prevent ownership conflicts in CI
git config --global --add safe.directory '*'

echo "=== System Architecture ==="
uname -a

echo "=== Cloning Flutter SDK ($FLUTTER_VERSION) ==="
git clone --branch "$FLUTTER_VERSION" --depth 1 https://github.com/flutter/flutter.git
export PATH="$PATH:$(pwd)/flutter/bin"

# Disable Flutter analytics and tracking
flutter config --no-analytics

echo "=== Verifying Flutter Installation ==="
flutter --version

echo "=== Initializing Flutter Web Platform ==="
cd frontend
flutter create --platforms=web .

echo "=== Fetching Flutter Dependencies ==="
flutter pub get

echo "=== Building Flutter Web App ==="
flutter build web --release --dart-define=BACKEND_URL=/api --verbose

echo "=== Build Completed Successfully ==="
