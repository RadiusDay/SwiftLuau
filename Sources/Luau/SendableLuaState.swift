/// A wrapper around a Lua state that can be sent across threads.
public final class SendableLuaState: @unchecked Sendable {
    /// The underlying Lua state pointer.
    public let value: OpaquePointer

    /// Initialize a SendableLuaState.
    /// - Parameter value: The underlying Lua state pointer.
    private init(value: OpaquePointer) {
        self.value = value
    }

    /// Create a sendable box from a Luau state.
    public static func from(_ state: LuaState) -> SendableLuaState {
        return SendableLuaState(value: state.state)
    }

    /// Take the Lua state back out of the box.
    /// Note: this is unsafe because the original LuaState may have been deallocated.
    /// There is no other way to do this, though.
    public func take() -> LuaState {
        return LuaState.from(value)
    }
}
