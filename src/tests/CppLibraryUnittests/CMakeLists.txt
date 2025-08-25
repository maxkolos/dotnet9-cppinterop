cmake_minimum_required(VERSION 3.20)
project(reverse_string_tests LANGUAGES CXX)

include(FetchContent)

FetchContent_Declare(
  catch2
  URL https://github.com/catchorg/Catch2/archive/refs/tags/v2.13.10.tar.gz
  DOWNLOAD_EXTRACT_TIMESTAMP true
)

FetchContent_MakeAvailable(catch2)

add_subdirectory(../../CppLibrary CppLibrary_build)

add_executable(test_reverse_string test_reverse_string.cpp)
target_link_libraries(test_reverse_string PRIVATE reverse_string)

target_include_directories(test_reverse_string PRIVATE
    ${catch2_SOURCE_DIR}/single_include)