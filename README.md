# SwiftLuau

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FRadiusDay%2FSwiftLuau%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/RadiusDay/SwiftLuau)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FRadiusDay%2FSwiftLuau%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/RadiusDay/SwiftLuau)

A Swift library for integrating with Luau, Roblox's Lua variant.

## Caution

__**This project is in its early stages. The API may change, and there may be bugs. Use at your own risk.**__

## Features

- Seamless Swift-Luau interoperability
- High-performance execution
- Easy API for embedding Luau scripts

## Installation

Add the following to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/RadiusDay/SwiftLuau.git", from: "0.4.0")
]
```

## Usage

```swift
import Luau

guard let state = LuaState.create() else {
    fatalError("Failed to create Luau state")
}

// Add any globals here

state.enableSandbox() // Once sandboxing is enabled, the global table cannot be modified

let source = """
print("Hello from Luau!")
return 42, "foo", {1, 2, 3}
"""

guard let bytecode = LuaBytecode.compile(source: source) else {
    fatalError("Failed to compile lua app")
}

let loadResult = state.load(chunkName: "=source.luau", bytecode: bytecode)
guard case .success(let function) = loadResult else {
    if case let .failure(error) = loadResult {
        fatalError("Failed to load lua app: \(error.message ?? "unknown error")")
    } else {
        fatalError("Failed to load lua app: unknown error")
    }
}

let callResult = function.protectedCall(arguments: [])
guard case .success(let returnValues) = callResult else {
    if case let .failure(error) = callResult {
        fatalError("Failed to run lua app: \(error.message ?? "unknown error")")
    } else {
        fatalError("Failed to run lua app: unknown error")
    }
}

print("Lua app ran successfully; return values are: [\(returnValues.map { $0.toStringConverting() }.joined(separator: ", "))]")
```

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.

### Pull Request Guidelines

- Fork the repository and create your branch from `main`. Do not PR `main` to `main`. This will be rejected.
- Use conventional commits for commit messages. Please note that commit messages may be edited before merging.
- Ensure your code adheres to the existing style and conventions.
- Run `swift format --in-place --recursive .` to format your code.
- Add a description of your changes and the problem they solve. (AI tools may be used, but please review their output carefully.)

## License

ISC License
