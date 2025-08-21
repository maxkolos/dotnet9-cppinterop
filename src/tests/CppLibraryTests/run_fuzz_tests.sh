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

mkdir -p bin

clang++ -g -O1 -fsanitize=fuzzer,address,undefined \
  -I../../CppLibrary \
  test_reverse_string_fuzz.cpp \
  ../../CppLibrary/reverse_string.cpp \
  -o bin/fuzz_reverse_string && \
bin/fuzz_reverse_string -max_total_time=5