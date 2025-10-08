// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let cppDefines: [CXXSetting] = [
    .define("LUA_USE_LONGJMP", to: "1"),
    .define("LUA_API", to: "extern \"C\""),
    .define("LUACODE_API", to: "extern \"C\""),
    .define("LUACODEGEN_API", to: "extern \"C\""),
]
let linkerSettings: [LinkerSetting] = [
    .linkedLibrary("c++")
]

let package = Package(
    name: "SwiftLuau",
    platforms: [
        .macOS(.v12),
        .macCatalyst(.v13),
        .iOS(.v16),
        .tvOS(.v16),
        .watchOS(.v10),
        .visionOS(.v1),
    ],
    products: [
        .library(
            name: "Luau",
            targets: ["Luau"]
        )
    ],
    targets: [
        .target(
            name: "CLuaAnalysis",
            dependencies: ["CLuaAst", "CLuaEqSat", "CLuaConfig", "CLuaCompiler", "CLuaVM"],
            path: "lib/Luau/Analysis",
            cxxSettings: cppDefines,
            linkerSettings: linkerSettings
        ),
        .target(
            name: "CLuaAst",
            dependencies: ["CLuaCommon"],
            path: "lib/Luau/Ast",
            cxxSettings: cppDefines,
            linkerSettings: linkerSettings
        ),
        .target(
            name: "CLuaCodeGen",
            dependencies: ["CLuaVM", "CLuaVMInternal", "CLuaCommon"],
            path: "lib/Luau/CodeGen",
            cxxSettings: cppDefines,
            linkerSettings: linkerSettings
        ),
        .target(
            name: "CLuaCommon",
            cxxSettings: cppDefines,
            linkerSettings: linkerSettings
        ),
        .target(
            name: "CLuaCompiler",
            dependencies: ["CLuaAst"],
            path: "lib/Luau/Compiler",
            cxxSettings: cppDefines,
            linkerSettings: linkerSettings
        ),
        .target(
            name: "CLuaConfig",
            dependencies: ["CLuaAst"],
            path: "lib/Luau/Config",
            cxxSettings: cppDefines,
            linkerSettings: linkerSettings
        ),
        .target(
            name: "CLuaEqSat",
            dependencies: ["CLuaCommon"],
            path: "lib/Luau/EqSat",
            cxxSettings: cppDefines,
            linkerSettings: linkerSettings
        ),
        .target(
            name: "CLuaVM",
            dependencies: ["CLuaCommon"],
            path: "lib/Luau/VM",
            cxxSettings: cppDefines,
            linkerSettings: linkerSettings
        ),
        .target(
            name: "CLuaVMInternal",
            dependencies: ["CLuaCommon", "CLuaVM"],
            path: "lib/Luau/VM",
            sources: [],
            publicHeadersPath: "src",
            cxxSettings: cppDefines,
            linkerSettings: linkerSettings
        ),
        .target(
            name: "CLua",
            dependencies: [
                "CLuaAst",
                "CLuaCompiler",
                "CLuaVM",
            ]
        ),
        .target(
            name: "Luau",
            dependencies: ["CLua"],
            publicHeadersPath: "include",
            linkerSettings: [
                .linkedLibrary("c++")
            ]
        ),
        .executableTarget(
            name: "Example",
            dependencies: ["Luau"]
        ),
    ],
    cxxLanguageStandard: .cxx17
)
