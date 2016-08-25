/*
 * Copyright (c) 2016, Joe Roback <joe.roback@gmail.com>. All Rights Reserved.
 */
#pragma once

/// deletes copy ctor and assignment
#define NODE_CLANG_NO_COPYABLE(CLASS)         \
    CLASS(const CLASS&) = delete;             \
    CLASS& operator=(const CLASS&) = delete

/// deletes move ctor and assignment
#define NODE_CLANG_NO_MOVEABLE(CLASS)         \
    CLASS(CLASS&&) = delete;                  \
    CLASS& operator=(CLASS&&) = delete

/// defaults copy ctor and assignment
#define NODE_CLANG_DEFAULT_COPYABLE(CLASS)    \
    CLASS(const CLASS&) = default;            \
    CLASS& operator=(const CLASS&) = default

/// defaults move ctor and assignment
#define NODE_CLANG_DEFAULT_MOVEABLE(CLASS)    \
    CLASS(CLASS&&) = default;                 \
    CLASS& operator=(CLASS&&) = default
