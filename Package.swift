// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let cppFlags: [CXXSetting] = [
    // Include paths
    .headerSearchPath("../Analysis/include"),
    .headerSearchPath("../Ast/include"),
    .headerSearchPath("../CodeGen/include"),
    .headerSearchPath("../Common/include"),
    .headerSearchPath("../Compiler/include"),
    .headerSearchPath("../Config/include"),
    .headerSearchPath("../EqSat/include"),
    .headerSearchPath("../VM/include"),

    // C++ standard
    .unsafeFlags(["-std=c++17"]),
    .define("LUA_USE_LONGJMP", to: "1"),
    .define("LUA_API", to: "extern \"C\""),
    .define("LUACODE_API", to: "extern \"C\""),
    .define("LUACODEGEN_API", to: "extern \"C\""),
]

let package = Package(
    name: "Luau",
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
        ),
        .executable(name: "Example", targets: []),
    ],
    targets: [
        .target(
            name: "CLuaAnalysis",
            path: "lib/Luau/Analysis",
            cxxSettings: cppFlags
        ),
        .target(
            name: "CLuaAst",
            path: "lib/Luau/Ast",
            cxxSettings: cppFlags
        ),
        .target(
            name: "CLuaCodeGen",
            path: "lib/Luau/CodeGen",
            cxxSettings: cppFlags + [.headerSearchPath("../VM/src")]
        ),
        .target(
            name: "CLuaCompiler",
            path: "lib/Luau/Compiler",
            cxxSettings: cppFlags
        ),
        .target(
            name: "CLuaConfig",
            path: "lib/Luau/Config",
            cxxSettings: cppFlags
        ),
        .target(
            name: "CLuaEqSat",
            path: "lib/Luau/EqSat",
            cxxSettings: cppFlags
        ),
        .target(
            name: "CLuaVM",
            path: "lib/Luau/VM",
            cxxSettings: cppFlags
        ),
        .target(
            name: "CLua",
            dependencies: [
                "CLuaAnalysis",
                "CLuaAst",
                "CLuaCodeGen",
                "CLuaCompiler",
                "CLuaConfig",
                "CLuaEqSat",
                "CLuaVM",
            ],
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
            dependencies: ["Luau"],
            resources: [
                .copy("Resources/luaApp.luau")
            ]
        ),
    ]
)
