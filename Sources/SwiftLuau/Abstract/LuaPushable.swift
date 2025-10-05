import SwiftLuauBindings

public protocol LuaPushable {
    /// Push the value onto the given Lua state.
    /// - Parameter state: The Lua state to push the value onto.
    func push(to state: LuaState)
}

extension String: LuaPushable {
    public func push(to state: LuaState) {
        let bytes = [UInt8](self.utf8)
        lua_pushlstring(state.state, bytes, bytes.count)
    }
}

extension Int32: LuaPushable {
    public func push(to state: LuaState) {
        lua_pushinteger(state.state, self)
    }
}

extension UInt32: LuaPushable {
    public func push(to state: LuaState) {
        lua_pushunsigned(state.state, self)
    }
}

extension Double: LuaPushable {
    public func push(to state: LuaState) {
        lua_pushnumber(state.state, self)
    }
}

extension Bool: LuaPushable {
    public func push(to state: LuaState) {
        lua_pushboolean(state.state, self ? 1 : 0)
    }
}
