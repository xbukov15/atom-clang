/*
 * Copyright (c) 2016, Joe Roback <joe.roback@gmail.com>. All Rights Reserved.
 */
#include <nan.h>

#include "clang_translationunit.hpp"


namespace node_clang
{

void initialize(v8::Local<v8::Object> exports)
{
    clang_translationunit::initialize(exports);
}

NODE_MODULE(clang, initialize)

}
