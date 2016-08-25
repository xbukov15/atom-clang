/*
 * Copyright (c) 2016, Joe Roback <joe.roback@gmail.com>. All Rights Reserved.
 */

#include <string>

#include <clang-c/Index.h>

#include <nan.h>

#include "clang_helpers.hpp"
#include "clang_translationunit.hpp"


namespace node_clang
{

static void clangVersion(const Nan::FunctionCallbackInfo<v8::Value>& info)
{
    std::string version = to_string(clang_getClangVersion());
    info.GetReturnValue().Set(Nan::New<v8::String>(version).ToLocalChecked());
}

void initialize(v8::Local<v8::Object> exports)
{
    clang_translationunit::initialize(exports);

    Nan::Set(exports,
             Nan::New<v8::String>("clangVersion").ToLocalChecked(),
             Nan::GetFunction(Nan::New<v8::FunctionTemplate>(clangVersion)).ToLocalChecked());
}

NODE_MODULE(clang, initialize)

}
