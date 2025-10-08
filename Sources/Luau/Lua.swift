import CLua

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

    public static func setTop(_ state: LuaState, _ index: Int32) {
        lua_settop(state.state, index)
    }

    public static func push(_ state: LuaState, at index: Int32) {
        lua_pushvalue(state.state, index)
    }

    public static func pop(_ state: LuaState, _ n: Int32 = 1) {
        lua_settop(state.state, -n - 1)
    }

    public static func insert(_ state: LuaState, at index: Int32) {
        lua_insert(state.state, index)
    }

    public static func remove(_ state: LuaState, at index: Int32) {
        lua_remove(state.state, index)
    }

    #if !hasFeature(Embedded)
    public static func error(_ state: LuaState, data: LuaPushable?) -> Never {
        data?.push(to: state)
        lua_error(state.state)
    }
    #else
    public static func error(_ state: LuaState, data: LuaDynPushable?) -> Never {
        data?.push(to: state)
        lua_error(state.state)
    }

    public static func error<T: LuaPushable>(_ state: LuaState, data: T) -> Never {
        data.push(to: state)
        lua_error(state.state)
    }
    #endif
}
