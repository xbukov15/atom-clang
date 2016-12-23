cmake_minimum_required(VERSION 3.2)
project(clang)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake")

if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE "Release")
endif()

set(CMAKE_CXX_FLAGS         "${CMAKE_CXX_FLAGS} -Wall -Wextra")
set(CMAKE_CXX_FLAGS_DEBUG   "-O0 -g")
set(CMAKE_CXX_FLAGS_RELEASE "-O3 -g")

# set link-time optimization on if Release, INTERPROCEDURAL_OPTIMIZATION target property does not seem to work
if ("${CMAKE_CXX_COMPILER_ID}" MATCHES "Clang" OR "${CMAKE_CXX_COMPILER_ID}" MATCHES "GNU")
    set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -flto")
endif()

find_package(LibClang 3.8.0 REQUIRED)
find_package(Boost 1.54 COMPONENTS filesystem REQUIRED)

add_definitions(
    -D_REENTRANT
    -D_GNU_SOURCE
    -DCLANG_SEARCH_PATH="${LIBCLANG_SEARCH_PATH}"
    ${LIBCLANG_DEFINITIONS}
)

include_directories(SYSTEM
    ${LIBCLANG_INCLUDE_DIR}
    ${Boost_INCLUDE_DIRS}
    ${CMAKE_JS_INC}
)

set(CLANG_SOURCES
    src/clang.cpp
    src/clang_helpers.cpp
    src/clang_translationunit.cpp
    src/command_line_args.cpp
    src/completion.cpp
    src/diagnostic.cpp
    src/unsaved_files.cpp
)

add_library(${PROJECT_NAME} SHARED ${CLANG_SOURCES})
set_target_properties(${PROJECT_NAME} PROPERTIES PREFIX "" SUFFIX ".node")
set_target_properties(${PROJECT_NAME} PROPERTIES CXX_STANDARD 11 CXX_STANDARD_REQUIRED ON)
set_target_properties(${PROJECT_NAME} PROPERTIES INTERPROCEDURAL_OPTIMIZATION ON)
target_link_libraries(${PROJECT_NAME} ${LIBCLANG_LIBRARIES})
target_link_libraries(${PROJECT_NAME} ${Boost_LIBRARIES})
target_link_libraries(${PROJECT_NAME} ${CMAKE_JS_LIB})
