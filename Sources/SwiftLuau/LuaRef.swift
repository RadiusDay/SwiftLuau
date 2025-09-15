import SwiftLuauBindings

/// A reference to a Lua value stored in the registry.
///
/// Having an active `LuaRef` makes Lua not garbage collect the referenced value.
/// When the `LuaRef` is deinitialized, the reference is removed from the registry.
public final class LuaRef: Sendable {
    private let state: SendableLuaState
    private let ref: Int32

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
    /// - Returns: A LuaRef referencing the stored value.
    public static func store(_ index: Int32, in state: LuaState) -> LuaRef {
        let ref = lua_ref(state.state, index)
        return LuaRef(state: state, ref: ref)
    }

    /// Push the referenced value onto the stack.
    public func push() {
        lua_rawgeti(state.value, Lua.registryIndex, ref)
    }
}
