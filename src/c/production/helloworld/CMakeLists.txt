cmake_minimum_required(VERSION 3.16)

project(helloworld C)
set(CMAKE_C_STANDARD 11)

include_directories(helloworld PRIVATE include)
add_library(helloworld SHARED src/helloworld.c include/helloworld.h)
