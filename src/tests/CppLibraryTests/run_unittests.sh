#!/bin/bash
set -x

LIBRARY_TESTS_DIR=$(pwd)

BUILD_DIR="$LIBRARY_TESTS_DIR"/bin
THIRD_PARTY="../../third_party"
CATCH_FILE="$THIRD_PARTY/catch.hpp"

mkdir -p "$THIRD_PARTY"
mkdir -p "$BUILD_DIR"

# Make sure the catch library is downloaded.
if [ ! -f "$CATCH_FILE" ]; then
    echo "Downloading Catch2 (v2.13.10)..."
    curl -L -o "$CATCH_FILE" https://github.com/catchorg/Catch2/releases/download/v2.13.10/catch.hpp
fi

g++ -std=c++17 -Wall \
    -I../../CppLibrary \
    -I"$THIRD_PARTY" \
    test_reverse_string.cpp ../../CppLibrary/reverse_string.cpp \
    -o "$BUILD_DIR/test_reverse_string" && \
    "$BUILD_DIR/test_reverse_string"