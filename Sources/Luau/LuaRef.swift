import CLua

/// A reference to a Lua value stored in the registry.
///
/// Having an active `LuaRef` makes Lua not garbage collect the referenced value.
/// When the `LuaRef` is deinitialized, the reference is removed from the registry.
public final class LuaRef: Sendable, LuaPushable {
    public let state: SendableLuaState
    public let ref: Int32

    deinit {
        lua_unref(state.value, ref)
    }

    /// Private initializer.
    /// - Parameters:
    ///   - state: The Lua state.
    ///   - ref: The reference.
    private init(state: LuaState, ref: Int32) {
        self.state = SendableLuaState.from(state)
        self.ref = ref
    }

    /// Store the value at the given index in the registry and return a LuaRef to it.
    /// - Parameters:
    ///   - index: The stack index of the value to store.
    ///   - state: The Lua state.
    ///   - remove: Whether to remove the value from the stack after storing it. Default is true.
    /// - Returns: A LuaRef referencing the stored value.
    public static func store(_ index: Int32, in state: LuaState, remove: Bool = true) -> LuaRef {
        let ref = lua_ref(state.state, index)
        // Remove the item at the given index if requested
        if remove {
            Lua.remove(state, at: index)
        }
        return LuaRef(state: state, ref: ref)
    }

    /// Push the referenced value onto the stack.
    public func push(to state: LuaState) {
        assert(self.state.value == state.state, "LuaState mismatch")
        lua_rawgeti(state.state, Lua.registryIndex, ref)
    }
}
