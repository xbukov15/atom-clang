# Try to find LibClang
#
# Optional LLVM_CONFIG_PATH environment variable can be set to override default PATH searching
#
# Once done this will define
#  LIBCLANG_FOUND - System has LibClang
#  LIBCLANG_VERSION - LibClang version
#  LIBCLANG_DEFINITIONS - Compiler switches required for using LibClang
#  LIBCLANG_INCLUDE_DIRS - The LibClang include directories
#  LIBCLANG_LIBRARIES - The libraries needed to use LibClang
#  LIBCLANG_SEARCH_PATH - The default search directory for includes

set(LLVM_CONFIG_NAMES
    llvm-config-4.0 llvm-config-3.9 llvm-config-3.8
    llvm-config-mp-4.0 llvm-config-mp-3.9 llvm-config-mp-3.8
    llvm-config
)

# first try and find llvm-config in LLVM_PATH environment variable
find_program(LLVM_CONFIG
    NAMES ${LLVM_CONFIG_NAMES}
    PATHS ENV LLVM_CONFIG_PATH NO_DEFAULT_PATH
)

if(NOT LLVM_CONFIG)
    find_program(LLVM_CONFIG
        NAMES ${LLVM_CONFIG_NAMES}
    )
endif()

if(NOT LLVM_CONFIG)
    message(FATAL_ERROR "Cannot find program: llvm-config")
endif()

execute_process(
    COMMAND ${LLVM_CONFIG} --version
    OUTPUT_VARIABLE LLVM_CONFIG_VERSION
    OUTPUT_STRIP_TRAILING_WHITESPACE)

execute_process(
    COMMAND ${LLVM_CONFIG} --includedir
    OUTPUT_VARIABLE LLVM_CONFIG_INCLUDEDIR
    OUTPUT_STRIP_TRAILING_WHITESPACE)
find_path(LIBCLANG_INCLUDE_DIR clang-c/Index.h HINTS ${LLVM_CONFIG_INCLUDEDIR})
mark_as_advanced(LIBCLANG_INCLUDE_DIR)

execute_process(
    COMMAND ${LLVM_CONFIG} --libdir
    OUTPUT_VARIABLE LLVM_CONFIG_LIBDIR
    OUTPUT_STRIP_TRAILING_WHITESPACE)
find_library(LIBCLANG_LIBRARY NAMES clang HINTS ${LLVM_CONFIG_LIBDIR})
mark_as_advanced(LIBCLANG_LIBRARY)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(LibClang
    FOUND_VAR LIBCLANG_FOUND
    REQUIRED_VARS LIBCLANG_LIBRARY LIBCLANG_INCLUDE_DIR
    VERSION_VAR LLVM_CONFIG_VERSION)

if(LIBCLANG_FOUND)
    set(LIBCLANG_DEFINITIONS
        -D__STDC_CONSTANT_MACROS
        -D__STDC_FORMAT_MACROS
        -D__STDC_LIMIT_MACROS
    )
    set(LIBCLANG_VERSION ${LLVM_CONFIG_VERSION})
    set(LIBCLANG_INCLUDE_DIRS ${LIBCLANG_INCLUDE_DIR})
    set(LIBCLANG_LIBRARIES ${LIBCLANG_LIBRARY})
    set(LIBCLANG_SEARCH_PATH "${LLVM_CONFIG_LIBDIR}/clang/${LLVM_CONFIG_VERSION}/include")
endif()
