import SwiftLuauBindings

/// A Luau state.
/// This is a thin wrapper around `OpaquePointer` to ensure proper memory management.
public final class LuaState {
    /// The underlying Luau state pointer.
    public private(set) var state: OpaquePointer
    /// Whether this state owns the Luau state and should free it on deinit.
    private var owned: Bool

    /// Initialize a LuaState.
    /// - Parameters:
    ///   - state: The underlying Luau state pointer.
    ///   - owned: Whether this state owns the Luau state and should free it on deinit.
    private init(state: OpaquePointer, owned: Bool = false) {
        self.state = state
        self.owned = owned
    }

    /// Deinitialize the LuaState.
    deinit {
        guard owned else { return }
        lua_close(state)
    }

    /// From a pointer.
    /// - Parameter pointer: The raw Luau state pointer.
    /// - Returns: A LuaState wrapping the pointer.
    public static func from(_ pointer: OpaquePointer) -> LuaState {
        return LuaState(state: pointer)
    }

    /// From an optional pointer.
    /// - Parameter pointer: The raw Luau state pointer.
    /// - Returns: A LuaState wrapping the pointer, or nil if the pointer is nil.
    public static func from(optional: OpaquePointer?) -> LuaState? {
        guard let pointer = optional else {
            return nil
        }
        return LuaState(state: pointer)
    }

    /// Create a new Luau state.
    /// - Parameters:
    ///   - openLibs: Whether to open the standard libraries.
    ///   - sandbox: Whether to sandbox the state.
    /// - Returns: A new LuaState if successful, nil otherwise.
    public static func create(openLibs: Bool = true) -> LuaState? {
        guard let state = luaL_newstate() else {
            return nil
        }
        if openLibs {
            luaL_openlibs(state)
        }
        return LuaState(state: state, owned: true)
    }

    /// Enable the Luau sandbox.
    public func enableSandbox() {
        luaL_sandbox(state)
    }

    /// Get the error message from the top of the stack.
    /// - Returns: The error message, or nil if there is no error.
    private func getErrorMessage() -> String? {
        return LuaString.get(from: self, at: -1)
    }

    /// Load a chunk of Luau bytecode with the given name.
    /// - Parameters:
    ///   - chunkName: The name of the chunk.
    ///   - bytecode: The Luau bytecode to load.
    /// - Returns: A result indicating success or failure.
    public func load(chunkName: String, bytecode: LuaBytecode) -> SwiftLuaResult<Void, String?> {
        let result = luau_load(state, chunkName, bytecode.data, bytecode.size, 0)
        if result != LUA_OK.rawValue {
            return .failure(getErrorMessage())
        }
        return .success(())
    }

    /// Set a global variable in the Lua state.
    /// - Parameters:
    ///   - name: The name of the global variable.
    ///   - value: The value to set the global variable to.
    public func setGlobal(name: String) {
        lua_setfield(state, Lua.globalsIndex, name)
    }
}
