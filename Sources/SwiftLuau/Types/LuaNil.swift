import SwiftLuauBindings

/// Lua nil type. Represents the absence of a value in Lua.
public enum LuaNil {
    /// Push a nil value onto the Lua stack.
    /// - Parameter state: The Lua state to push to.
    public static func push(to state: LuaState) {
        lua_pushnil(state.state)
    }

    /// Check if the value at the given index is nil.
    /// - Parameters:
    ///   - index: The stack index to check.
    ///   - state: The Lua state to check in.
    /// - Returns: True if the value is nil, false otherwise.
    public static func isNil(at index: Int32, in state: LuaState) -> Bool {
        lua_type(state.state, index) == LUA_TNIL.rawValue
    }
}