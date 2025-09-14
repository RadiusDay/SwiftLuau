import SwiftLuauBindings

/// Boolean functions for Lua.
public enum LuaBoolean {
    /// Push a Swift boolean onto the Lua stack.
    /// - Parameters:
    ///   - value: The boolean value to push.
    ///   - state: The Lua state to push to.
    public static func push(_ value: Bool, to state: LuaState) {
        lua_pushboolean(state.state, value ? 1 : 0)
    }

    /// Get a Swift boolean from the Lua stack.
    /// - Parameters:
    ///   - index: The stack index to get the value from.
    ///   - state: The Lua state to get the value from.
    /// - Returns: The boolean value if it exists and is a boolean, nil otherwise.
    public static func get(from state: LuaState, at index: Int32) -> Bool? {
        guard LuaType.get(from: state, at: index) == .boolean else {
            return nil
        }
        return lua_toboolean(state.state, index) != 0
    }

    /// Get a Swift boolean from the Lua stack, converting the value to a boolean if necessary.
    /// - Parameters:
    ///   - index: The stack index to get the value from.
    ///   - state: The Lua state to get the value from.
    /// - Returns: The boolean value if it exists or can be converted to a boolean, nil otherwise.
    public static func getConverting(from state: LuaState, at index: Int32) -> Bool {
        return lua_toboolean(state.state, index) != 0
    }
}
