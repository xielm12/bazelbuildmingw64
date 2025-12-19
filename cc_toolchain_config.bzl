load("@bazel_tools//tools/cpp:cc_toolchain_config_lib.bzl", 
    "action_config",
    "artifact_name_pattern",
    "feature",
    "flag_group",
    "flag_set",
    "tool_path")
load("@bazel_tools//tools/build_defs/cc:action_names.bzl", "ACTION_NAMES")

def _impl(ctx):
    base_path = ctx.attr.tool_bin_path
    if not base_path.endswith("/") and not base_path.endswith("\\"):
        base_path = base_path + "/"

    tool_paths = [
        tool_path(name = "gcc", path = base_path + "g++.exe"),
        tool_path(name = "ld", path = base_path + "ld.exe"),
        tool_path(name = "ar", path = base_path + "ar.exe"),
        tool_path(name = "cpp", path = base_path + "cpp.exe"),
        tool_path(name = "gcov", path = base_path + "gcov.exe"),
        tool_path(name = "nm", path = base_path + "nm.exe"),
        tool_path(name = "objdump", path = base_path + "objdump.exe"),
        tool_path(name = "strip", path = base_path + "strip.exe"),
    ]
    
    # Define action configs
    action_configs = []
    
    # Define features
    features = [
        feature(
            name = "default_linker_flags",
            enabled = True,
            flag_sets = [
                flag_set(
                    actions = [ACTION_NAMES.cpp_link_executable],
                    flag_groups = [
                        flag_group(
                            flags = ["-lstdc++", "-lm"],
                        ),
                    ],
                ),
            ],
        ),
    ]
    
    return cc_common.create_cc_toolchain_config_info(
        ctx = ctx,
        toolchain_identifier = ctx.attr.toolchain_identifier,
        host_system_name = "local",
        target_system_name = "local",
        target_cpu = "x64_windows",
        target_libc = "unknown",
        compiler = "mingw-gcc",
        abi_version = "unknown",
        abi_libc_version = "unknown",
        tool_paths = tool_paths,
        cxx_builtin_include_directories = ctx.attr.include_directories,
        artifact_name_patterns = [
            artifact_name_pattern(
                category_name = "executable",
                prefix = "",
                extension = ".exe",
            ),
        ],
        features = features,
        action_configs = action_configs,
    )

cc_toolchain_config = rule(
    implementation = _impl,
    attrs = {
        "tool_bin_path": attr.string(mandatory = True, doc = "The path to the bin directory of the toolchain"),
        "include_directories": attr.string_list(default = [], doc = "The list of builtin include directories"),
        "toolchain_identifier": attr.string(default = "mingw-toolchain", doc = "Identifier for the toolchain"),
    },
    provides = [CcToolchainConfigInfo],
)

def mingw_toolchain(name, tool_bin_path, include_directories):
    """
    Macro to define a MinGW toolchain.
    
    Args:
        name: The name of the toolchain target.
        tool_bin_path: Path to the bin directory containing MinGW tools.
        include_directories: List of system include directories.
    """
    
    # Configuration target
    config_name = name + "_config"
    cc_toolchain_config(
        name = config_name,
        tool_bin_path = tool_bin_path,
        include_directories = include_directories,
        toolchain_identifier = name,
    )
    
    # Empty filegroup for toolchain files
    empty_name = name + "_empty"
    native.filegroup(name = empty_name)
    
    # Toolchain definition
    toolchain_def_name = name + "_def"
    native.cc_toolchain(
        name = toolchain_def_name,
        toolchain_identifier = name,
        toolchain_config = ":" + config_name,
        all_files = ":" + empty_name,
        compiler_files = ":" + empty_name,
        dwp_files = ":" + empty_name,
        linker_files = ":" + empty_name,
        objcopy_files = ":" + empty_name,
        strip_files = ":" + empty_name,
        supports_param_files = 0,
    )
    
    # Toolchain registration target
    native.toolchain(
        name = name,
        exec_compatible_with = [
            "@platforms//cpu:x86_64",
            "@platforms//os:windows",
        ],
        target_compatible_with = [
            "@platforms//cpu:x86_64",
            "@platforms//os:windows",
        ],
        toolchain = ":" + toolchain_def_name,
        toolchain_type = "@bazel_tools//tools/cpp:toolchain_type",
    )
