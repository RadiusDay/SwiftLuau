import SwiftLuauBindings

/// Light userdata functions for Lua.
public enum LuaLightUserdata {
    /// Push a light userdata onto the Lua stack.
    /// - Parameters:
    ///   - pointer: The pointer to push as light userdata.
    ///   - state: The Lua state to push to.
    public static func push(_ pointer: UnsafeMutableRawPointer, to state: LuaState) {
        lua_pushlightuserdatatagged(state.state, pointer, 0)
    }

    /// Get a light userdata from the Lua stack.
    /// - Parameters:
    ///   - index: The stack index to get the value from.
    ///   - state: The Lua state to get the value from.
    /// - Returns: The light userdata if it exists and is a light userdata, nil otherwise.
    public static func get(from state: LuaState, at index: Int32) -> UnsafeMutableRawPointer? {
        if LuaType.get(from: state, at: index) != .lightUserdata {
            return nil
        }
        return lua_tolightuserdatatagged(state.state, index, 0)
    }
}
