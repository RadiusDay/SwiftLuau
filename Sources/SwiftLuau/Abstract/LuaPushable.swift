public protocol LuaPushable {
    /// Push the value onto the given Lua state.
    /// - Parameter state: The Lua state to push the value onto.
    func push(to state: LuaState)
}

extension String: LuaPushable {
    public func push(to state: LuaState) {
        LuaString.create(self, in: state).push(to: state)
    }
}

extension Int32: LuaPushable {
    public func push(to state: LuaState) {
        LuaNumber.create(self, in: state).push(to: state)
    }
}

extension Int: LuaPushable {
    public func push(to state: LuaState) {
        LuaNumber.create(Int32(self), in: state).push(to: state)
    }
}

extension Double: LuaPushable {
    public func push(to state: LuaState) {
        LuaNumber.create(self, in: state).push(to: state)
    }
}

extension Bool: LuaPushable {
    public func push(to state: LuaState) {
        LuaBoolean.create(self, in: state).push(to: state)
    }
}
