# MinGW Bazel Toolchain

This directory contains a reusable MinGW toolchain configuration for Bazel.

## Publishing to GitHub

To share this toolchain, you can push this directory to a GitHub repository (e.g., `my-mingw-toolchain`).

### 1. Repository Structure
Ensure the repository root looks like this:

```text
my-mingw-toolchain/
├── MODULE.bazel          # (Create this file, see below)
├── BUILD                 # (Empty or exports bzl files)
└── cc_toolchain_config.bzl
```

### 2. Create `MODULE.bazel`
Create a `MODULE.bazel` file in the root of the new repository:

```starlark
module(
    name = "mingw_toolchain",
    version = "1.0.0",
    compatibility_level = 1,
)

bazel_dep(name = "rules_cc", version = "0.0.9")
bazel_dep(name = "platforms", version = "0.0.10")
```

### 3. Clean up `BUILD`
Ensure the `BUILD` file exports the Starlark file so others can use it. It shouldn't contain hardcoded paths like the local example.

```starlark
package(default_visibility = ["//visibility:public"])
exports_files(["cc_toolchain_config.bzl"])
```

---

## Usage in Other Projects

To use this toolchain in another Bazel project:

### 1. Add dependency in `MODULE.bazel`

```starlark
bazel_dep(name = "mingw_toolchain")

git_override(
    module_name = "mingw_toolchain",
    remote = "https://github.com/xielm12/bazelbuildmingw64.git",
    commit = "<COMMIT_HASH>",
)

register_toolchains("//toolchains:my_mingw_toolchain")
```

### 2. Configure in `toolchains/BUILD` (or any package)

In your project, create a `BUILD` file (e.g., in `toolchains/BUILD`) and define a toolchain using your local paths:

```starlark
load("@mingw_toolchain//:cc_toolchain_config.bzl", "mingw_toolchain")

mingw_toolchain(
    name = "my_mingw_toolchain",
    tool_bin_path = "D:/scoop/apps/msys2/2024-12-08/ucrt64/bin", # <--- Your local path
    include_directories = [
        "D:/scoop/apps/msys2/2024-12-08/ucrt64/include",     # <--- Your local includes
        "D:/scoop/apps/msys2/2024-12-08/ucrt64/lib/gcc",
        "D:/scoop/apps/msys2/2024-12-08/usr/include",
    ],
)
```
