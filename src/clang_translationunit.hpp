/*
 * Copyright (c) 2016, Joe Roback <joe.roback@gmail.com>. All Rights Reserved.
 */
#pragma once

#include <string>
#include <mutex>

#include <clang-c/Index.h>

#include <nan.h>

#include "completion.hpp"
#include "diagnostic.hpp"


namespace node_clang
{

class command_line_args;
class unsaved_files;

/**
 * main object created by javascript side to parse code and provide code completion
 * parsing and code completions are done on libuv thread via Nan and results are returned
 * via Promises
 */
class clang_translationunit final
    : public Nan::ObjectWrap
{
    friend class parse_worker;
    friend class completion_worker;

public:
    static void initialize(v8::Local<v8::Object> exports);

private:
    /**
     * called to create a new clang_translationunit object from javascript
     */
    static void allocate(const Nan::FunctionCallbackInfo<v8::Value>& info);

    /**
     * parse the current translation unit
     */
    static void parse(const Nan::FunctionCallbackInfo<v8::Value>& info);

    /**
     * get all code completions at a given line, column
     */
    static void completions(const Nan::FunctionCallbackInfo<v8::Value>& info);

    /**
     * destroy any clang memory used. since JS is garbage collected,
     * this method provides a way for the user to explicitly and instantly
     * deallocate memory from libclang
     */
    static void dispose(const Nan::FunctionCallbackInfo<v8::Value>& info);

    static v8::Local<v8::Object> wrapMyObject(clang_translationunit* obj);

private:
    static Nan::Persistent<v8::Function> constructor;

public:
    explicit clang_translationunit(const std::string& filename);
    ~clang_translationunit();

    const std::string filename() const& noexcept
    {
        return _filename;
    }

private:
    /**
     * @param force_parse force a full parse instead of a reparse (e.g. if command line args have changed)
     * @param command_line_args set of arguments to pass into libclang for compiling this translation unit
     * @param unsaved_file any unsaved file contents that libclang needs to provide up to date parsing and completions
     */
    int parse(bool force_parse,
              command_line_args& command_line_args,
              unsaved_files& unsaved_files,
              std::vector<diagnostic>& diagnostics);

    /**
     * @param filename full filename and path
     * @param line line number
     * @param column column number
     * @param unsaved_file any unsaved file contents that libclang needs to provide up to date parsing and completions
     * @param deprecated true will include completions marked with the attribute __deprecated__
     */
    std::vector<completion> completions(const std::string& filename,
                                        unsigned line,
                                        unsigned column,
                                        unsaved_files& unsaved_files,
                                        bool deprecated);

    /**
     * release any memory associated with this translation unit from libclang
     */
    void dispose();

private:
    std::mutex _lock;
    std::string _filename;
    CXIndex _index;
    CXTranslationUnit _tunit;
};

}
