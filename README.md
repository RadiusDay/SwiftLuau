# SwiftLuau

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
    .package(url: "https://github.com/yourusername/SwiftLuau.git", from: "0.1.0")
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

guard let bytecode = LuaBytecode.compile(source: luaAppSource) else {
    fatalError("Failed to compile lua app")
}

// Load the bytecode into the Luau state
let loadResult = state.load(chunkName: "luaApp", bytecode: bytecode)
guard case .success = loadResult else {
    if case let .failure(error) = loadResult {
        fatalError("Failed to load lua app: \(error ?? "unknown error")")
    } else {
        fatalError("Failed to load lua app: unknown error")
    }
}

// Call the loaded chunk
let callResult = LuaFunction.protectedCall(from: state, nargs: 0, nresults: 1)
guard case .success = callResult else {
    if case let .failure(error) = callResult {
        fatalError("Failed to run lua app: \(error)")
    } else {
        fatalError("Failed to run lua app: unknown error")
    }
}
```

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.

## License

ISC License
