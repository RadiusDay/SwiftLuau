import SwiftLuauBindings

/// Table functions for Lua.
public enum LuaTable {
    /// Push an empty table onto the Lua stack.
    /// - Parameter state: The Lua state to push to.
    public static func pushEmpty(to state: LuaState) {
        lua_createtable(state.state, 0, 0)
    }

    /// Set an item in a table.
    /// - Parameters:
    ///   - state: The Lua state to set the item in.
    ///   - index: The stack index of the table to set the item in.
    public static func setItem(in state: LuaState, at index: Int32) {
        lua_settable(state.state, index)
    }

    /// Set an item in a table at the given index on the stack.
    /// - Parameters:
    ///   - state: The Lua state to set the item in.
    ///   - index: The stack index of the table to set the item in.
    ///   - key: The key to set the item at.
    public static func setItem(in state: LuaState, at index: Int32, key: Int32) {
        lua_rawseti(state.state, index, key)
    }

    /// Load an item from a table at the given index on the stack.
    /// - Parameters:
    ///   - state: The Lua state to load the item from.
    ///   - index: The stack index of the table to load the item from.
    public static func loadItem(from state: LuaState, at index: Int32) {
        lua_gettable(state.state, index)
    }

    /// Load an item from a table at the given index on the stack.
    /// - Parameters:
    ///   - state: The Lua state to load the item from.
    ///   - index: The stack index of the table to load the item from.
    ///   - key: The key to load the item from.
    public static func loadItem(from state: LuaState, at index: Int32, key: Int32) {
        lua_rawgeti(state.state, index, key)
    }

    /// Set the metatable.
    public static func setMetatable(in state: LuaState, at index: Int32) {
        lua_setmetatable(state.state, index)
    }
}
