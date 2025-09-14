import CoreFoundation
import SwiftLuauBindings

/// Functions related to Lua userdata.
public struct LuaUserdata: Sendable {
    public let buffer: [UInt8]
    public let deallocater: @convention(c) (UnsafeMutableRawPointer?) -> Void

    /// Create a LuaUserdata.
    /// - Parameters:
    ///   - buffer: The buffer pointer.
    ///   - deallocater: A deallocater function to free the userdata when no longer needed.
    public init(buffer: [UInt8], deallocater: @convention(c) (UnsafeMutableRawPointer?) -> Void) {
        self.buffer = buffer
        self.deallocater = deallocater
    }

    /// Push a userdata onto the Lua stack.
    /// - Parameters:
    ///   - userdata: The userdata to push.
    ///   - state: The Lua state to push to.
    public static func push(_ userdata: LuaUserdata, to state: LuaState) {
        userdata.buffer.withUnsafeBytes { rawBuffer in
            guard let baseAddress = rawBuffer.baseAddress else {
                fatalError("Failed to get base address of userdata buffer")
            }
            let ptr = lua_newuserdatadtor(state.state, rawBuffer.count, userdata.deallocater)
            if let dst = ptr {
                dst.copyMemory(from: baseAddress, byteCount: rawBuffer.count)
            }
        }
    }

    /// Get a userdata from the Lua stack.
    /// - Parameters:
    ///   - index: The stack index to get the value from.
    ///   - state: The Lua state to get the value from.
    /// - Returns: The userdata if it exists and is a userdata, nil otherwise.
    public static func get(from state: LuaState, at index: Int32) -> UnsafeMutableRawPointer? {
        let userdata = lua_touserdata(state.state, index)
        return userdata
    }
}