import SwiftLuauBindings
import Foundation

/// Buffer functions for Lua.
public struct LuaBuffer: @unchecked Sendable {
    public let buffer: Data

    /// Initialize a LuaBuffer with Data.
    /// - Parameter buffer: The Data to initialize the buffer with.
    public init(buffer: Data) {
        self.buffer = buffer
    }

    /// Push a Lua buffer onto the Lua stack as a string.
    /// - Parameters:
    ///   - buffer: The LuaBuffer to push.
    ///   - state: The Lua state to push to.
    public static func push(_ buffer: LuaBuffer, to state: LuaState) {
        let bufferPtr = lua_newbuffer(state.state, buffer.buffer.count)
        buffer.buffer.withUnsafeBytes { rawBuffer in
            guard let baseAddress = rawBuffer.baseAddress else {
                fatalError("Failed to get base address of buffer")
            }
            if let dst = bufferPtr {
                dst.copyMemory(from: baseAddress, byteCount: rawBuffer.count)
            }
        }
    }

    /// Get a Lua buffer from the Lua stack at the given index.
    /// - Parameters:
    ///   - index: The stack index to get the value from.
    ///   - state: The Lua state to get the value from.
    /// - Returns: The LuaBuffer if it exists and is a buffer, nil otherwise.
    public static func get(from state: LuaState, at index: Int32) -> LuaBuffer? {
        var size: size_t = 0
        guard let ptr = lua_tobuffer(state.state, index, &size) else {
            return nil
        }
        let buffer = Data(bytes: ptr, count: size)
        return LuaBuffer(buffer: buffer)
    }
}
