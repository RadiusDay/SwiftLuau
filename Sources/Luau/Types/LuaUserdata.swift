import CLua
import CoreFoundation

/// Functions related to Lua userdata.
public struct LuaUserdata: Sendable, LuaPushable, LuaGettable {
    public let reference: LuaRef

    /// Create a LuaUserdata from a LuaRef.
    /// - Parameter reference: The LuaRef to initialize the userdata with.
    public init(reference: LuaRef) {
        self.reference = reference
    }

    /// Create LuaUserdata from a buffer and a deallocater function.
    /// - Parameters:
    ///   - buffer: The buffer pointer.
    ///   - deallocater: A deallocater function to free the userdata when no longer needed.
    public static func create(
        buffer: [UInt8],
        deallocater: @convention(c) (UnsafeMutableRawPointer?) -> Void,
        in state: LuaState
    ) -> LuaUserdata {
        buffer.withUnsafeBytes { rawBuffer in
            guard let baseAddress = rawBuffer.baseAddress else {
                fatalError("Failed to get base address of userdata buffer")
            }
            let ptr = lua_newuserdatadtor(state.state, rawBuffer.count, deallocater)
            if let dst = ptr {
                dst.copyMemory(from: baseAddress, byteCount: rawBuffer.count)
            }
        }
        let ref = LuaRef.store(-1, in: state)
        return LuaUserdata(reference: ref)
    }

    /// Push the Lua userdata onto the Lua stack.
    /// - Parameter state: The Lua state to push to.
    public func push(to state: LuaState) {
        reference.push(to: state)
    }

    /// Get a Lua userdata from the Lua stack at the given index.
    /// - Parameters:
    ///   - state: The Lua state to get the userdata from.
    ///   - index: The stack index to get the userdata from.
    /// - Returns: The LuaUserdata if it exists and is a userdata, nil otherwise.
    public static func get(from state: LuaState, at index: Int32) -> LuaUserdata? {
        if LuaType.get(from: state, at: index) != .userdata {
            return nil
        }
        let ref = LuaRef.store(index, in: state)
        return LuaUserdata(reference: ref)
    }

    /// Get the raw pointer to the userdata.
    /// - Returns: The raw pointer to the userdata if it exists, nil otherwise.
    public func toPointer() -> UnsafeMutableRawPointer? {
        let state = reference.state.take()
        push(to: state)
        if LuaType.get(from: state, at: -1) != .userdata {
            Lua.pop(state, 1)
            return nil
        }
        let userdata = lua_touserdata(state.state, -1)
        Lua.pop(state, 1)
        return userdata
    }
}
