import SwiftLuauBindings

/// Representation of a Lua boolean value.
public struct LuaBoolean: Sendable, LuaPushable, LuaGettableNonOptional {
    /// The reference to the Lua boolean.
    public let reference: LuaRef

    /// Initialize a LuaBoolean with a LuaRef.
    /// - Parameter reference: The LuaRef to initialize the boolean with.
    public init(reference: LuaRef) {
        self.reference = reference
    }

    /// Create a LuaBoolean from a Swift boolean.
    /// - Parameters:
    ///   - value: The Swift boolean to wrap.
    ///   - state: The Lua state to create the boolean in.
    /// - Returns: A LuaBoolean wrapping the provided Swift boolean.
    public static func create(_ value: Bool, in state: LuaState) -> LuaBoolean {
        lua_pushboolean(state.state, value ? 1 : 0)
        let ref = LuaRef.store(-1, in: state)
        return LuaBoolean(reference: ref)
    }

    /// Push the Lua boolean onto the Lua stack.
    /// - Parameter state: The Lua state to push the boolean to.
    public func push(to state: LuaState) {
        reference.push(to: state)
    }

    /// Get a Lua boolean from the Lua stack at the given index.
    /// - Parameters:
    ///   - index: The stack index to get the value from.
    ///   - state: The Lua state to get the value from.
    /// - Returns: The LuaBoolean if it exists and is a boolean, nil otherwise.
    public static func get(from state: LuaState, at index: Int32) -> LuaBoolean {
        let ref = LuaRef.store(index, in: state)
        return LuaBoolean(reference: ref)
    }

    /// Convert the Lua boolean to a Swift boolean.
    /// - Returns: The Swift boolean value.
    public func toBool() -> Bool? {
        let state = reference.state.take()
        push(to: state)
        if LuaType.get(from: state, at: -1) != .boolean {
            Lua.pop(state, 1)
            return nil
        }
        let boolValue = lua_toboolean(state.state, -1) != 0
        Lua.pop(state, 1)
        return boolValue
    }

    /// Convert the Lua boolean to a Swift boolean, converting the value if necessary.
    /// - Returns: The Swift boolean value.
    public func toBoolConverting() -> Bool {
        let state = reference.state.take()
        push(to: state)
        let boolValue = lua_toboolean(state.state, -1) != 0
        Lua.pop(state, 1)
        return boolValue
    }

    // /// Push a Swift boolean onto the Lua stack.
    // /// - Parameters:
    // ///   - value: The boolean value to push.
    // ///   - state: The Lua state to push to.
    // public static func push(_ value: Bool, to state: LuaState) {
    //     lua_pushboolean(state.state, value ? 1 : 0)
    // }

    // /// Get a Swift boolean from the Lua stack.
    // /// - Parameters:
    // ///   - index: The stack index to get the value from.
    // ///   - state: The Lua state to get the value from.
    // /// - Returns: The boolean value if it exists and is a boolean, nil otherwise.
    // public static func get(from state: LuaState, at index: Int32) -> Bool? {
    //     guard LuaType.get(from: state, at: index) == .boolean else {
    //         return nil
    //     }
    //     return lua_toboolean(state.state, index) != 0
    // }

    // /// Get a Swift boolean from the Lua stack, converting the value to a boolean if necessary.
    // /// - Parameters:
    // ///   - index: The stack index to get the value from.
    // ///   - state: The Lua state to get the value from.
    // /// - Returns: The boolean value if it exists or can be converted to a boolean, nil otherwise.
    // public static func getConverting(from state: LuaState, at index: Int32) -> Bool {
    //     return lua_toboolean(state.state, index) != 0
    // }
}
