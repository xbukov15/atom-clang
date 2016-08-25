/*
 * Copyright (c) 2016, Joe Roback <joe.roback@gmail.com>. All Rights Reserved.
 */
#include "command_line_args.hpp"

namespace node_clang
{

command_line_args::command_line_args(const v8::Local<v8::Array>& js_command_line_args)
{
    std::uint32_t length = js_command_line_args->Length();
    _data.reserve(length);

    for (std::uint32_t i = 0; i < length; ++i)
    {
        if (Nan::Has(js_command_line_args, i).FromJust())
        {
            auto element = Nan::Get(js_command_line_args, i).ToLocalChecked()->ToString();
            std::size_t element_length = element->Utf8Length();

            char* element_data = new char[element_length + 1];
            Nan::DecodeWrite(element_data, element_length, element, Nan::UTF8);
            element_data[element_length] = '\0';

            _data.emplace_back(element_data);
        }
    }
}

command_line_args::~command_line_args() noexcept
{
    dispose();
}

void command_line_args::dispose() & noexcept
{
    if (!_data.empty())
    {
        for (auto& command_line_arg : _data)
        {
            delete command_line_arg;
        }

        _data.clear();
        _data.shrink_to_fit();
    }
}

}
