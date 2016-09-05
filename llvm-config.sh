#!/usr/bin/env bash

# if the LLVM_CONFIG environment variable is not set, attempt to search for various
# known naming conventions of llvm-config, looking for the latest version

[[ -z ${LLVM_CONFIG} ]] \
    && LLVM_CONFIG=$(which llvm-config 2>/dev/null) \
    || LLVM_CONFIG=$(which llvm-config-4.2 2>/dev/null) \
    || LLVM_CONFIG=$(which llvm-config-4.1 2>/dev/null) \
    || LLVM_CONFIG=$(which llvm-config-4.0 2>/dev/null) \
    || LLVM_CONFIG=$(which llvm-config-3.9 2>/dev/null) \
    || LLVM_CONFIG=$(which llvm-config-3.8 2>/dev/null) \
    || LLVM_CONFIG=$(which llvm-config-mp-4.2 2>/dev/null) \
    || LLVM_CONFIG=$(which llvm-config-mp-4.1 2>/dev/null) \
    || LLVM_CONFIG=$(which llvm-config-mp-4.0 2>/dev/null) \
    || LLVM_CONFIG=$(which llvm-config-mp-3.9 2>/dev/null) \
    || LLVM_CONFIG=$(which llvm-config-mp-3.8 2>/dev/null)

echo -n ${LLVM_CONFIG}
