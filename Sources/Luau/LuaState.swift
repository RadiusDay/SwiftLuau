import CLua

/// A Luau state.
/// This is a thin wrapper around `OpaquePointer` to ensure proper memory management.
public final class LuaState {
    public struct LoadFailure: Error {
        public let message: String?

        internal init(message: String?) {
            self.message = message
        }

        public var localizedDescription: String {
            return message ?? "Unknown error"
        }
    }

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
    private func getErrorMessage() -> LoadFailure {
        return LoadFailure(message: LuaString.get(from: self, at: -1).toStringConverting())
    }

    /// Load a chunk of Luau bytecode with the given name.
    /// - Parameters:
    ///   - chunkName: The name of the chunk.
    ///   - bytecode: The Luau bytecode to load.
    /// - Returns: A result indicating success or failure.
    public func load(chunkName: String, bytecode: LuaBytecode) -> Result<Void, LoadFailure> {
        let result = luau_load(state, chunkName, bytecode.data, bytecode.size, 0)
        if result != LUA_OK.rawValue {
            return .failure(getErrorMessage())
        }
        return .success(())
    }

    /// Set a global variable in the Lua state.
    /// - Parameters:
    ///   - key: The name of the global variable.
    ///   - value: The value to set the global variable to.
    public func setGlobal(
        key: String,
        to value: LuaPushable
    ) {
        value.push(to: self)
        lua_setfield(state, Lua.globalsIndex, key)
    }

    /// Get a global variable from the Lua state.
    /// - Parameter key: The name of the global variable.
    /// - Returns: The value of the global variable, or nil if it does not exist or is nil.
    public func getGlobal<Type: LuaGettable>(
        type: Type.Type,
        key: String,
    ) -> Type? {
        lua_getfield(state, Lua.globalsIndex, key)
        let value = Type.get(from: self, at: -1)
        Lua.pop(self, 1)
        return value
    }

    /// Get a global table from the Lua state.
    /// - Returns: The global table, or nil if it does not exist or is not a table.
    public func getGlobal<Type: LuaGettableNonOptional>(
        type: Type.Type,
        key: String
    ) -> Type {
        lua_getfield(state, Lua.globalsIndex, key)
        let value = Type.get(from: self, at: -1)
        Lua.pop(self, 1)
        return value
    }
}
