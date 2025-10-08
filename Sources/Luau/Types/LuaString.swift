import CLua

/// String functions for Lua.
public struct LuaString: LuaPushable, LuaGettableNonOptional {
    public let reference: LuaRef

    /// Initialize a LuaString with a LuaRef.
    /// - Parameter reference: The LuaRef to initialize the string with.
    public init(reference: LuaRef) {
        self.reference = reference
    }

    /// Create a LuaString from a Swift string.
    /// - Parameters:
    ///   - value: The Swift string to wrap.
    ///   - state: The Lua state to create the string in.
    /// - Returns: A LuaString wrapping the provided Swift string.
    public static func create(_ value: String, in state: LuaState) -> LuaString {
        let bytes = [UInt8](value.utf8)
        lua_pushlstring(state.state, bytes, bytes.count)
        let ref = LuaRef.store(-1, in: state)
        return LuaString(reference: ref)
    }

    /// Push the Lua string onto the Lua stack.
    /// - Parameter state: The Lua state to push the string to.
    public func push(to state: LuaState) {
        reference.push(to: state)
    }

    /// Get a Lua string from the Lua stack at the given index.
    /// - Parameters:
    ///   - index: The stack index to get the value from.
    ///   - state: The Lua state to get the value from.
    /// - Returns: The string if it exists and is a string, nil otherwise.
    public static func get(from state: LuaState, at index: Int32) -> LuaString {
        let ref = LuaRef.store(index, in: state)
        return LuaString(reference: ref)
    }

    private func stringFrom(bytes: UnsafePointer<Int8>?, length: size_t) -> String? {
        guard let chars = bytes else {
            return nil
        }
        #if hasFeature(Embedded)
        return String(
            validating: UnsafeBufferPointer(
                start: UnsafeMutableRawPointer(mutating: chars).assumingMemoryBound(to: UInt8.self),
                count: Int(length)
            ),
            as: UTF8.self
        )
        #else
        return String(
            bytes: UnsafeBufferPointer(
                start: UnsafeMutableRawPointer(mutating: chars).assumingMemoryBound(to: UInt8.self),
                count: Int(length)
            ),
            encoding: .utf8
        )
        #endif
    }

    /// Get the swift string value of the Lua string.
    /// - Returns: The swift string if it exists and is a string, nil otherwise.
    public func toString() -> String? {
        push(to: reference.state)
        if LuaType.get(from: reference.state, at: -1) != .string {
            Lua.pop(reference.state, 1)
            return nil
        }
        var length: size_t = 0
        guard let chars = lua_tolstring(reference.state.state, -1, &length) else {
            Lua.pop(reference.state, 1)
            return nil
        }
        Lua.pop(reference.state, 1)
        return stringFrom(bytes: chars, length: length)
    }

    /// Get the swift string value of the Lua string, converting the value to a string if necessary.
    /// - Returns: The string if it exists or can be converted to a string, nil otherwise.
    public func toStringConverting() -> String? {
        push(to: reference.state)
        var length: size_t = 0
        guard let chars = luaL_tolstring(reference.state.state, -1, &length) else {
            Lua.pop(reference.state, 1)
            return nil
        }
        Lua.pop(reference.state, 1)
        return stringFrom(bytes: chars, length: length)
    }
}
