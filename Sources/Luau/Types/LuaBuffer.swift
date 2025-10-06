import CLua

#if canImport(Foundation)
import Foundation
#endif

/// Representation of a Lua buffer.
public struct LuaBuffer: LuaPushable, LuaGettable {
    /// The Data wrapped by the buffer.
    public let reference: LuaRef

    /// Initialize a LuaBuffer with a LuaRef.
    /// - Parameter reference: The LuaRef to initialize the buffer with.
    public init(reference: LuaRef) {
        self.reference = reference
    }

    /// Create a LuaBuffer from a byte array.
    /// - Parameters:
    ///   - data: The byte array to wrap.
    ///   - state: The Lua state to create the buffer in.
    /// - Returns: A LuaBuffer wrapping the provided Data.
    public static func create(_ bytes: [UInt8], in state: LuaState) -> LuaBuffer {
        bytes.withUnsafeBytes { rawBuffer in
            guard let baseAddress = rawBuffer.baseAddress else {
                fatalError("Failed to get base address of buffer")
            }
            let ptr = lua_newbuffer(state.state, rawBuffer.count)
            if let dst = ptr {
                dst.copyMemory(from: baseAddress, byteCount: rawBuffer.count)
            }
        }
        let ref = LuaRef.store(-1, in: state)
        return LuaBuffer(reference: ref)
    }

    #if canImport(Foundation)
    /// Create a LuaBuffer from Data.
    /// - Parameters:
    ///   - data: The Data to wrap.
    ///   - state: The Lua state to create the buffer in.
    /// - Returns: A LuaBuffer wrapping the provided Data.
    public static func create(_ data: Data, in state: LuaState) -> LuaBuffer {
        data.withUnsafeBytes { rawBuffer in
            guard let baseAddress = rawBuffer.baseAddress else {
                fatalError("Failed to get base address of buffer")
            }
            let ptr = lua_newbuffer(state.state, rawBuffer.count)
            if let dst = ptr {
                dst.copyMemory(from: baseAddress, byteCount: rawBuffer.count)
            }
        }
        let ref = LuaRef.store(-1, in: state)
        return LuaBuffer(reference: ref)
    }
    #endif

    /// Push the Lua buffer onto the Lua stack as a string.
    /// - Parameter state: The Lua state to push the buffer to.
    public func push(to state: LuaState) {
        reference.push(to: state)
    }

    public static func get(from state: LuaState, at index: Int32) -> LuaBuffer? {
        if LuaType.get(from: state, at: index) != .buffer {
            return nil
        }
        let ref = LuaRef.store(index, in: state)
        return LuaBuffer(reference: ref)
    }

    /// Get the byte array of a Lua buffer.
    /// - Returns: The byte array if it exists and is a buffer, nil otherwise.
    public func toBytes() -> [UInt8]? {
        push(to: reference.state)
        var size: size_t = 0
        guard let ptr = lua_tobuffer(reference.state.state, -1, &size) else {
            Lua.pop(reference.state, 1)
            return nil
        }
        let buffer: [UInt8] = .init(
            UnsafeBufferPointer(start: ptr.assumingMemoryBound(to: UInt8.self), count: size)
        )
        Lua.pop(reference.state, 1)
        return buffer
    }

    #if canImport(Foundation)
    /// Get the Data value of the Lua buffer.
    /// - Returns: The Data value if it exists and is a buffer, nil otherwise.
    public func toData() -> Data? {
        push(to: reference.state)
        var size: size_t = 0
        guard let ptr = lua_tobuffer(reference.state.state, -1, &size) else {
            Lua.pop(reference.state, 1)
            return nil
        }
        let buffer = Data(bytes: ptr, count: size)
        Lua.pop(reference.state, 1)
        return buffer
    }
    #endif
}
