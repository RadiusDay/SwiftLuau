import CLua

/// Representation of a Lua number.
public struct LuaNumber: Sendable, LuaPushable, LuaGettable {
    /// A reference to the Lua state.
    public let reference: LuaRef

    /// Initialize a LuaNumber with a LuaRef.
    /// - Parameter reference: The LuaRef to initialize the number with.
    public init(reference: LuaRef) {
        self.reference = reference
    }

    /// Create a LuaNumber from a Double.
    /// - Parameters:
    ///   - value: The Double value to wrap.
    ///   - state: The Lua state to create the number in.
    /// - Returns: A LuaNumber wrapping the provided Double value.
    public static func create(_ value: Double, in state: LuaState) -> LuaNumber {
        lua_pushnumber(state.state, value)
        let ref = LuaRef.store(-1, in: state)
        return LuaNumber(reference: ref)
    }

    /// Create a LuaNumber from a Int.
    /// - Parameters:
    ///   - value: The Double value to wrap.
    ///   - state: The Lua state to create the number in.
    /// - Returns: A LuaNumber wrapping the provided Double value.
    public static func create(_ value: Int32, in state: LuaState) -> LuaNumber {
        lua_pushinteger(state.state, value)
        let ref = LuaRef.store(-1, in: state)
        return LuaNumber(reference: ref)
    }

    /// Create a LuaNumber from a UInt32.
    /// - Parameters:
    ///   - value: The UInt32 value to wrap.
    ///   - state: The Lua state to create the number in.
    /// - Returns: A LuaNumber wrapping the provided UInt32 value.
    public static func create(_ value: UInt32, in state: LuaState) -> LuaNumber {
        lua_pushunsigned(state.state, value)
        let ref = LuaRef.store(-1, in: state)
        return LuaNumber(reference: ref)
    }

    /// Get the Double value of the Lua number.
    /// - Returns: The Double value if it exists and is a number, nil otherwise.
    public func toDouble() -> Double {
        let state = reference.state.take()
        push(to: state)
        let data = lua_tonumberx(state.state, -1, nil)
        Lua.pop(state, 1)
        return data
    }

    /// Push the Lua number onto the Lua stack.
    /// - Parameter state: The Lua state to push the number to.
    public func push(to state: LuaState) {
        reference.push(to: state)
    }

    /// Get a Lua number from the Lua stack at the given index.
    /// - Parameters:
    ///   - state: The Lua state to get the number from.
    ///   - index: The stack index to get the number from.
    /// - Returns: The Lua number if it exists and is a number, nil otherwise.
    public static func get(from state: LuaState, at index: Int32) -> LuaNumber? {
        if LuaType.get(from: state, at: index) != .number {
            return nil
        }
        let ref = LuaRef.store(index, in: state)
        return LuaNumber(reference: ref)
    }
}
