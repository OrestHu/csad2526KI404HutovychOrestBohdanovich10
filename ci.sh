#!/usr/bin/env bash
set -euo pipefail

BUILD_DIR="build"
CONFIG="${1:-Release}"

mkdir -p "$BUILD_DIR"
cmake -S . -B "$BUILD_DIR" -DCMAKE_BUILD_TYPE="$CONFIG"
cmake --build "$BUILD_DIR" --config "$CONFIG"
ctest --test-dir "$BUILD_DIR" --build-config "$CONFIG" --output-on-failure
