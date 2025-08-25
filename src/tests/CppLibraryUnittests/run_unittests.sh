#!/usr/bin/env bash
set -x
set -e

cmake -S . -B bin
cmake --build bin
./bin/test_reverse_string