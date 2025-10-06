public protocol LuaGettable {
    /// Get a value from the given Lua state at the specified index.
    /// - Parameters:
    ///   - state: The Lua state to get the value from.
    ///   - index: The stack index to get the value from.
    /// - Returns: The value if it exists and is of the correct type, nil otherwise.
    static func get(from state: LuaState, at index: Int32) -> Self?
}

public protocol LuaGettableNonOptional {
    /// Get a value from the given Lua state at the specified index.
    /// - Parameters:
    ///   - state: The Lua state to get the value from.
    ///   - index: The stack index to get the value from.
    /// - Returns: The value if it exists and is of the correct type, nil otherwise.
    static func get(from state: LuaState, at index: Int32) -> Self
}
