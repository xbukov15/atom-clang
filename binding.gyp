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
      "cflags!": [
      ],
      "cflags_cc!": [
      ],
      "cflags": [
        "-O2",
        "-flto",
      ],
      "cflags_cc": [
        "-std=c++11",
        "-O2",
        "-flto",
      ],
      "ldflags": [
        "-flto",
      ],
      "xcode_settings": {
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
        ],
      },
    },
  ]
}
