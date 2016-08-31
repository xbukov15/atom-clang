{
  "variables": {
    "llvm_config": "<!(./llvm-config.sh)"
  },
  "targets": [
    {
      "target_name": "clang",
      "sources": [
        "src/clang_translationunit.cpp",
        "src/clang.cpp",
        "src/clang_helpers.cpp",
        "src/command_line_args.cpp",
        "src/completion.cpp",
        "src/diagnostic.cpp",
        "src/unsaved_files.cpp",
      ],
      "defines": [
        "NDEBUG",
        "__STDC_CONSTANT_MACROS",
        "__STDC_FORMAT_MACROS",
        "__STDC_LIMIT_MACROS",
        "CLANG_SEARCH_PATH=\"<!(<(llvm_config) --libdir)/clang/<!(<(llvm_config) --version)/include\""
      ],
      "cflags!": [
      ],
      "cflags_cc!": [
      ],
      "cflags": [
        "-g",
        "-O2",
        "-flto",
      ],
      "cflags_cc": [
        "-g",
        "-std=c++11",
        "-O2",
        "-flto",
      ],
      "ldflags": [
        "-flto",
      ],
      "xcode_settings": {
        "GCC_GENERATE_DEBUGGING_SYMBOLS": "YES",
        "CLANG_CXX_LANGUAGE_STANDARD": "c++11",
        "GCC_OPTIMIZATION_LEVEL": "2",
        "OTHER_CFLAGS": [
          "-flto",
        ],
        "OTHER_LDFLAGS": [
          "-flto",
        ],
      },
      "include_dirs": [
        "<!(node -e \"require('nan')\")",
        "<!@(<(llvm_config) --includedir)",
      ],
      "link_settings": {
        "libraries": [
          "-Wl,-rpath,<!(<(llvm_config) --libdir)",
          "<!@(<(llvm_config) --ldflags)",
          "-lclang",
          "<!@(<(llvm_config) --system-libs)",
        ],
      },
    },
  ]
}
