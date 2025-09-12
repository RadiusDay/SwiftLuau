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

let state = LuauState()
let source = """
print("Hello from Luau!")
"""

guard let bytecode = LuauBytecode.compile(source: source) else {
    print("Failed to compile Luau source")
    return
}

// Load the bytecode into the Luau state
let loadStatus = luau.load(chunkName: "example", bytecode: bytecode)
if !loadStatus {
    print("Failed to load Luau bytecode")
    return
}
// Call the loaded chunk
let callStatus = luau.call()
if !callStatus {
    print("Failed to execute Luau bytecode")
    return
}
```

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.

## License

ISC License
