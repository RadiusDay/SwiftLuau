import CLua

/// Table functions for Lua.
public struct LuaTable: LuaPushable, LuaGettable {
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
        push(to: reference.state)
        metaTable.push(to: reference.state)
        lua_setmetatable(reference.state.state, -2)
        Lua.pop(reference.state, 1)
    }

    /// Get the meta table of the Lua table.
    /// - Parameter state: The Lua state to operate in.
    /// - Returns: The meta table if it exists, nil otherwise.
    public func getMetaTable() -> LuaTable? {
        push(to: reference.state)
        if lua_getmetatable(reference.state.state, -1) == 0 {
            Lua.pop(reference.state, 1)
            return nil
        }
        let ref = LuaRef.store(-1, in: reference.state)
        return LuaTable(reference: ref)
    }

    /// Get a value from the Lua table by key.
    /// - Parameters:
    ///   - type: The type to retrieve.
    ///   - key: The key to get the value for.
    ///   - state: The Lua state to operate in.
    /// - Returns: The value at the given key, or nil if it doesn't exist.
    public func get<Type: LuaGettable>(_ type: Type.Type, key: LuaPushable) -> Type? {
        push(to: reference.state)
        key.push(to: reference.state)
        lua_gettable(reference.state.state, -2)
        let value = Type.get(from: reference.state, at: -1)
        Lua.pop(reference.state, 1)
        return value
    }

    /// Get a value from the Lua table by key.
    /// - Parameters:
    ///   - type: The type to retrieve.
    ///   - key: The key to get the value for.
    ///   - state: The Lua state to operate in.
    /// - Returns: The value at the given key, or nil if it doesn't exist.
    public func get<Type: LuaGettableNonOptional>(_ type: Type.Type, key: LuaPushable) -> Type {
        push(to: reference.state)
        key.push(to: reference.state)
        lua_gettable(reference.state.state, -2)
        let value = Type.get(from: reference.state, at: -1)
        Lua.pop(reference.state, 1)
        return value
    }

    #if !hasFeature(Embedded)
    /// Set a value in the Lua table by key.
    /// - Parameters:
    ///   - key: The key to set the value for.
    ///   - value: The value to set.
    public func set(key: LuaPushable, to value: LuaPushable) {
        push(to: reference.state)
        key.push(to: reference.state)
        value.push(to: reference.state)
        lua_settable(reference.state.state, -3)
        Lua.pop(reference.state, 1)
    }
    #else
    /// Set a value in the Lua table by key.
    /// - Parameters:
    ///   - key: The key to set the value for.
    ///   - value: The value to set.
    public func set(key: LuaDynPushable, to value: LuaDynPushable) {
        push(to: reference.state)
        key.push(to: reference.state)
        value.push(to: reference.state)
        lua_settable(reference.state.state, -3)
        Lua.pop(reference.state, 1)
    }

    /// Set a value in the Lua table by key.
    /// - Parameters:
    ///   - key: The key to set the value for.
    ///   - value: The value to set.
    public func set<Key: LuaPushable, Value: LuaPushable>(key: Key, to value: Value) {
        push(to: reference.state)
        key.push(to: reference.state)
        value.push(to: reference.state)
        lua_settable(reference.state.state, -3)
        Lua.pop(reference.state, 1)
    }
    #endif
}
