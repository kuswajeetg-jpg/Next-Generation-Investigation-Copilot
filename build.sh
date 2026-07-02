#!/bin/bash
# Exit immediately if a command exits with a non-zero status
set -e

FLUTTER_VERSION="3.22.2"

echo "=== System Architecture ==="
uname -a

echo "=== Downloading Flutter SDK ($FLUTTER_VERSION) ==="
# Download stable Flutter SDK to local directory
curl -O "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"
tar xf "flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"
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
