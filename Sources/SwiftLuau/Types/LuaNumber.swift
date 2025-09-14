import SwiftLuauBindings

/// Functions related to Lua numbers.
public enum LuaNumber {
    /// Push a Double onto the Lua stack.
    /// - Parameters:
    ///   - value: The Double value to push.
    ///   - state: The Lua state to push to.
    public static func push(_ value: Double, to state: LuaState) {
        lua_pushnumber(state.state, value)
    }

    /// Get a Double from the Lua stack.
    /// - Parameters:
    ///   - index: The stack index to get the value from.
    ///   - state: The Lua state to get the value from.
    /// - Returns: The Double value if it exists and is a number, nil otherwise.
    public static func getDouble(from state: LuaState, at index: Int32) -> Double? {
        var isNum: Int32 = 0
        let num = lua_tonumberx(state.state, index, &isNum)
        return isNum != 0 ? num : nil
    }

    /// Push an Int32 onto the Lua stack.
    /// - Parameters:
    ///   - value: The Int32 value to push.
    ///   - state: The Lua state to push to.
    public static func push(_ value: Int32, to state: LuaState) {
        lua_pushinteger(state.state, value)
    }

    /// Get an Int32 from the Lua stack.
    /// - Parameters:
    ///   - index: The stack index to get the value from.
    ///   - state: The Lua state to get the value from.
    /// - Returns: The Int32 value if it exists and is a number, nil otherwise.
    public static func getInt32(from state: LuaState, at index: Int32) -> Int32? {
        var isNum: Int32 = 0
        let int = lua_tointegerx(state.state, index, &isNum)
        return isNum != 0 ? int : nil
    }

    /// Push a UInt32 onto the Lua stack.
    /// - Parameters:
    ///   - value: The UInt32 value to push.
    ///   - state: The Lua state to push to.
    public static func push(_ value: UInt32, to state: LuaState) {
        lua_pushunsigned(state.state, value)
    }

    /// Get a UInt32 from the Lua stack.
    /// - Parameters:
    ///   - index: The stack index to get the value from.
    ///   - state: The Lua state to get the value from.
    /// - Returns: The UInt32 value if it exists and is a number, nil otherwise.
    public static func getUInt32(from state: LuaState, at index: Int32) -> UInt32? {
        var isNum: Int32 = 0
        let uint = lua_tounsignedx(state.state, index, &isNum)
        return isNum != 0 ? uint : nil
    }
}
