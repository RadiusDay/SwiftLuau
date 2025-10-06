# SwiftLuau

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FRadiusDay%2FSwiftLuau%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/RadiusDay/SwiftLuau)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FRadiusDay%2FSwiftLuau%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/RadiusDay/SwiftLuau)

A Swift library for integrating with Luau, Roblox's Lua variant.

## Caution

This project is in its early stages. The API may change, and there may be bugs. Use at your own risk.

## Features

- Seamless Swift-Luau interoperability
- High-performance execution
- Easy API for embedding Luau scripts

## Installation

Add the following to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/RadiusDay/SwiftLuau.git", from: "0.2.0")
]
```

## Usage

```swift
import SwiftLuau

guard let state = LuaState.create() else {
    fatalError("Failed to create Luau state")
}
let source = """
print("Hello from Luau!")
"""

guard let bytecode = LuaBytecode.compile(source: source) else {
    fatalError("Failed to compile lua app")
}

let loadResult = state.load(chunkName: "=source.luau", bytecode: bytecode)
guard case .success = loadResult else {
    if case let .failure(error) = loadResult {
        fatalError("Failed to load lua app: \(error ?? "unknown error")")
    } else {
        fatalError("Failed to load lua app: unknown error")
    }
}

let ref = LuaRef.store(-1, in: state)
let function = LuaFunction(reference: ref)
let callResult = function.protectedCall(arguments: [], nresults: 1)
guard case .success = callResult else {
    if case let .failure(error) = callResult {
        fatalError("Failed to run lua app: \(error ?? "unknown error")")
    } else {
        fatalError("Failed to run lua app: unknown error")
    }
}

print("Lua script executed successfully")
```

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.

## License

ISC License
