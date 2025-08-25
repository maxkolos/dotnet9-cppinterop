cmake_minimum_required(VERSION 3.20)
project(reverse_string LANGUAGES CXX)

add_library(reverse_string SHARED
    reverse_string.cpp
)

set_target_properties(reverse_string PROPERTIES PREFIX "")

target_include_directories(reverse_string
    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}
)