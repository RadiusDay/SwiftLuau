import SwiftLuauBindings

/// Thread functions for Lua.
public struct LuaThread: @unchecked Sendable {
    public let thread: OpaquePointer

    /// Initialize a LuaThread with an existing thread pointer.
    /// - Parameter thread: The existing Lua thread pointer.
    public init(thread: OpaquePointer) {
        self.thread = thread
    }

    /// Create a new Lua thread.
    /// - Parameter state: The Lua state to create the thread in.
    /// - Returns: A new Lua thread.
    public static func create(in state: LuaState) -> LuaThread? {
        guard let thread = lua_newthread(state.state) else {
            return nil
        }
        return LuaThread(thread: thread)
    }

    /// Push a Lua thread onto the Lua stack.
    /// - Parameters:
    ///   - thread: The Lua thread to push.
    ///   - state: The Lua state to push to.
    public static func push(_ thread: LuaThread, to state: LuaState) {
        lua_pushthread(thread.thread)
    }

    /// Get a Lua thread from the Lua stack.
    /// - Parameters:
    ///   - index: The stack index to get the value from.
    ///   - state: The Lua state to get the value from.
    /// - Returns: The Lua thread if it exists and is a thread, nil otherwise.
    public static func get(from state: LuaState, at index: Int32) -> LuaThread? {
        guard let thread = lua_tothread(state.state, index) else {
            return nil
        }
        return LuaThread(thread: thread)
    }
}
