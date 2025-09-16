import SwiftLuauBindings

/// A reference to a Lua thread.
public struct LuaThread: Sendable, LuaPushable, LuaGettable {
    /// The reference to the Lua thread.
    public let reference: LuaRef

    /// Initialize a LuaThread with a LuaRef.
    /// - Parameter reference: The LuaRef to initialize the thread with.
    public init(reference: LuaRef) {
        self.reference = reference
    }

    /// Create a new Lua thread and return a LuaThread referencing it.
    /// - Parameter state: The Lua state to create the thread in.
    /// - Returns: A LuaThread referencing the new thread.
    public static func create(in state: LuaState) -> LuaThread? {
        if lua_newthread(state.state) == nil {
            return nil
        }
        let ref = LuaRef.store(-1, in: state)
        return LuaThread(reference: ref)
    }

    /// Push the Lua thread onto the Lua stack.
    /// - Parameter state: The Lua state to push the thread to.
    public func push(to state: LuaState) {
        reference.push(to: state)
    }

    /// Get a Lua thread from the Lua stack at the given index.
    /// - Parameters:
    ///   - state: The Lua state to get the thread from.
    ///   - index: The stack index to get the thread from.
    /// - Returns: A LuaThread if one exists at the given index, nil otherwise.
    public static func get(from state: LuaState, at index: Int32) -> LuaThread? {
        if LuaType.get(from: state, at: index) != .thread {
            return nil
        }
        let ref = LuaRef.store(-1, in: state)
        return LuaThread(reference: ref)
    }

    /// Get the underlying Lua state of the thread.
    /// - Returns: The LuaState of the thread.
    public func getState() -> LuaState? {
        let state = reference.state.take()
        push(to: state)
        guard let threadState = lua_tothread(state.state, -1) else {
            Lua.pop(state, 1)
            return nil
        }
        Lua.pop(state, 1)
        return LuaState.from(threadState)
    }
}
