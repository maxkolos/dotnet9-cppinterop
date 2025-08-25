#!/usr/bin/env bash
set -x
set -e

# Check whether clang is installed.
if ! command -v clang >/dev/null 2>&1; then
    echo "clang is not found, installing..."
    sudo apt update
    sudo apt install -y clang
    echo "clang is installed: $(clang --version | head -n1)"
fi

BUILD_DIR=bin

mkdir -p "$BUILD_DIR"

cmake -S . -B "$BUILD_DIR" -DCMAKE_CXX_COMPILER=clang++ 
cmake --build "$BUILD_DIR" --target fuzz_reverse_string
"$BUILD_DIR/fuzz_reverse_string" -max_total_time=5