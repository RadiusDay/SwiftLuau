import SwiftLuauBindings

/// Constants and functions related to the Lua C API.
public enum Lua {
    public static let registryIndex = -LUAI_MAXCSTACK - 2000
    public static let environIndex = -LUAI_MAXCSTACK - 2001
    public static let globalsIndex = -LUAI_MAXCSTACK - 2002
    public static func upvalueIndex(_ i: Int32) -> Int32 {
        return Lua.globalsIndex - i
    }

    public static func getTop(_ state: LuaState) -> Int32 {
        return lua_gettop(state.state)
    }

    public static func pop(_ state: LuaState, _ n: Int32 = 1) {
        lua_settop(state.state, -n - 1)
    }

    public static func error(_ state: LuaState) {
        lua_error(state.state)
    }
}
