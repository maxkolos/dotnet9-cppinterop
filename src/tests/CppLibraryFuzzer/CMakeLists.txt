cmake_minimum_required(VERSION 3.20)
project(CppLibraryFuzzTests LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

if (NOT CMAKE_CXX_COMPILER_ID MATCHES "Clang")
    message(FATAL_ERROR "Fuzzing requires clang++, but found ${CMAKE_CXX_COMPILER_ID}")
endif()

add_subdirectory(../../CppLibrary ${CMAKE_BINARY_DIR}/CppLibrary_build)

add_executable(fuzz_reverse_string
    test_reverse_string_fuzz.cpp
)

target_link_libraries(fuzz_reverse_string PRIVATE reverse_string)

target_include_directories(fuzz_reverse_string PRIVATE
    ../../CppLibrary
)

target_compile_options(fuzz_reverse_string PRIVATE
    -g -O1 -fsanitize=fuzzer,address,undefined
)
target_link_options(fuzz_reverse_string PRIVATE
    -fsanitize=fuzzer,address,undefined
)