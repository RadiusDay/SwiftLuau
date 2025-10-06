import CLua

/// Table functions for Lua.
public struct LuaTable: Sendable, LuaPushable, LuaGettable {
    /// The reference to the Lua table.
    public let reference: LuaRef

    /// Initialize a LuaTable with a LuaRef.
    /// - Parameter reference: The LuaRef to initialize the table with.
    public init(reference: LuaRef) {
        self.reference = reference
    }

    /// Create a new empty Lua table and return a LuaTable referencing it.
    /// - Parameter state: The Lua state to create the table in.
    /// - Returns: A LuaTable referencing the new table.
    public static func create(in state: LuaState) -> LuaTable {
        lua_createtable(state.state, 0, 0)
        let ref = LuaRef.store(-1, in: state)
        return LuaTable(reference: ref)
    }

    /// Push the Lua table onto the Lua stack.
    /// - Parameter state: The Lua state to push the table to.
    public func push(to state: LuaState) {
        reference.push(to: state)
    }

    /// Get a Lua table from the Lua stack at the given index.
    /// - Parameters:
    ///   - index: The stack index to get the value from.
    ///   - state: The Lua state to get the value from.
    /// - Returns: The LuaTable if it exists and is a table, nil otherwise.
    public static func get(from state: LuaState, at index: Int32) -> LuaTable? {
        if LuaType.get(from: state, at: index) != .table {
            return nil
        }
        let ref = LuaRef.store(index, in: state)
        return LuaTable(reference: ref)
    }

    /// Set a meta table for the Lua table.
    /// - Parameters:
    ///   - metaTable: The meta table to set.
    ///   - state: The Lua state to operate in.
    public func setMetaTable(_ metaTable: LuaTable) {
        let state = reference.state.take()
        push(to: state)
        metaTable.push(to: state)
        lua_setmetatable(state.state, -2)
        Lua.pop(state, 1)
    }

    /// Get the meta table of the Lua table.
    /// - Parameter state: The Lua state to operate in.
    /// - Returns: The meta table if it exists, nil otherwise.
    public func getMetaTable() -> LuaTable? {
        let state = reference.state.take()
        push(to: state)
        if lua_getmetatable(state.state, -1) == 0 {
            Lua.pop(state, 1)
            return nil
        }
        let ref = LuaRef.store(-1, in: state)
        return LuaTable(reference: ref)
    }

    /// Get a value from the Lua table by key.
    /// - Parameters:
    ///   - type: The type to retrieve.
    ///   - key: The key to get the value for.
    ///   - state: The Lua state to operate in.
    /// - Returns: The value at the given key, or nil if it doesn't exist.
    public func get<Type: LuaGettable>(_ type: Type.Type, key: LuaPushable) -> Type? {
        let state = reference.state.take()
        push(to: state)
        key.push(to: state)
        lua_gettable(state.state, -2)
        let value = Type.get(from: state, at: -1)
        Lua.pop(state, 1)
        return value
    }

    /// Get a value from the Lua table by key.
    /// - Parameters:
    ///   - type: The type to retrieve.
    ///   - key: The key to get the value for.
    ///   - state: The Lua state to operate in.
    /// - Returns: The value at the given key, or nil if it doesn't exist.
    public func get<Type: LuaGettableNonOptional>(_ type: Type.Type, key: LuaPushable) -> Type {
        let state = reference.state.take()
        push(to: state)
        key.push(to: state)
        lua_gettable(state.state, -2)
        let value = Type.get(from: state, at: -1)
        Lua.pop(state, 1)
        return value
    }

    /// Set a value in the Lua table by key.
    /// - Parameters:
    ///   - key: The key to set the value for.
    ///   - value: The value to set.
    public func set(key: LuaPushable, to value: LuaPushable) {
        let state = reference.state.take()
        push(to: state)
        key.push(to: state)
        value.push(to: state)
        lua_settable(state.state, -3)
        Lua.pop(state, 1)
    }
}
