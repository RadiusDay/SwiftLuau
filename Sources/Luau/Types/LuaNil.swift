import CLua

/// Representation of a Lua nil value.
public struct LuaNil: Sendable, LuaPushable, LuaGettable {
    public func push(to state: LuaState) {
        lua_pushnil(state.state)
    }

    public static func get(from state: LuaState, at index: Int32) -> LuaNil? {
        if LuaType.get(from: state, at: index) == .nilType {
            return LuaNil()
        }
        return nil
    }
}
