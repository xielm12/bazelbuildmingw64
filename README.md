# MinGW Bazel Toolchain

This directory contains a reusable MinGW toolchain configuration for Bazel.

## 1. Repository Structure
Ensure the repository root looks like this:

```text
bazelbuildmingw64/
├── MODULE.bazel          # (Create this file, see below)
├── BUILD                 # (Empty or exports bzl files)
└── cc_toolchain_config.bzl
```

---

## Usage in Other Projects

To use this toolchain in another Bazel project:

### 1. Add dependency in `MODULE.bazel`

```starlark
bazel_dep(name = "bazelbuildmingw64", version = "1.0")

git_override(
    module_name = "bazelbuildmingw64",
    remote = "https://github.com/xielm12/bazelbuildmingw64.git",
    commit = "7c02a9439cef741f2c5475db1c3997bc860afd16"
)

bazel_dep(name = "rules_cc", version = "0.2.16")
bazel_dep(name = "platforms", version = "1.0.0")
register_toolchains("//:mingw_cc_toolchain")
```

### 2. Configure in `BUILD` (or any package)

In your project, create a `BUILD` file (e.g., in `BUILD`) and define a toolchain using your local paths:

```starlark
load("@bazelbuildmingw64//:cc_toolchain_config.bzl", "mingw_toolchain")
package(default_visibility = ["//visibility:public"])

mingw_toolchain(
    name = "mingw_cc_toolchain",
    tool_bin_path = "D:/scoop/apps/msys2/2024-12-08/ucrt64/bin", # <--- Your local path
    include_directories = [
        "D:/scoop/apps/msys2/2024-12-08/ucrt64/include",     # <--- Your local includes
        "D:/scoop/apps/msys2/2024-12-08/ucrt64/lib/gcc",
        "D:/scoop/apps/msys2/2024-12-08/usr/include",
    ],
)

cc_binary(
    name = "hello",
    srcs = ["hello.cc"],
)
```

