import SwiftLuauBindings

/// Table functions for Lua.
public enum LuaTable {
    /// Push an empty table onto the Lua stack.
    /// - Parameter state: The Lua state to push to.
    public static func pushEmpty(to state: LuaState) {
        lua_createtable(state.state, 0, 0)
    }

    private static func pushValue(_ value: LuaType, to state: LuaState) {
        switch value {
        case .nilType:
            LuaNil.push(to: state)
        case .boolean(let bool):
            LuaBoolean.push(bool, to: state)
        case .double(let double):
            LuaNumber.push(double, to: state)
        case .integer(let int):
            LuaNumber.push(int, to: state)
        case .unsignedInteger(let uint):
            LuaNumber.push(uint, to: state)
        case .string(let string):
            LuaString.push(string, to: state)
        case .vector(let vector):
            LuaVector.push(vector, to: state)
        case .table(let table):
            LuaTable.push(table, to: state)
        case .function(let function):
            LuaFunction.push(function, to: state)
        case .userdata(let userdata):
            LuaUserdata.push(userdata, to: state)
        case .thread(let thread):
            LuaThread.push(thread, to: state)
        case .buffer(let buffer):
            LuaBuffer.push(buffer, to: state)
        }
    }

    /// Set an item in a table at the given index on the stack.
    /// - Parameters:
    ///   - state: The Lua state to set the item in.
    ///   - index: The stack index of the table to set the item in.
    ///   - key: The key to set the item at.
    ///   - value: The value to set the item to.
    public static func setItem(in state: LuaState, at index: Int32, key: String, value: LuaType) {
        pushValue(value, to: state)
        lua_setfield(state.state, index, key)
    }

    /// Set an item in a table at the given index on the stack.
    /// - Parameters:
    ///   - state: The Lua state to set the item in.
    ///   - index: The stack index of the table to set the item in.
    ///   - key: The key to set the item at.
    ///   - value: The value to set the item to.
    public static func setItem(in state: LuaState, at index: Int32, key: Int32, value: LuaType) {
        pushValue(value, to: state)
        lua_rawseti(state.state, index, key)
    }

    /// Load an item from a table at the given index on the stack.
    /// - Parameters:
    ///   - state: The Lua state to load the item from.
    ///   - index: The stack index of the table to load the item from.
    ///   - key: The key to load the item from.
    /// - Returns: The value at the given key, or nil if it does not exist
    public static func loadItem(from state: LuaState, at index: Int32, key: String) {
        lua_getfield(state.state, index, key)
    }

    /// Load an item from a table at the given index on the stack.
    /// - Parameters:
    ///   - state: The Lua state to load the item from.
    ///   - index: The stack index of the table to load the item from.
    ///   - key: The key to load the item from.
    /// - Returns: The value at the given key, or nil if it does not exist
    public static func loadItem(from state: LuaState, at index: Int32, key: Int32) {
        lua_rawgeti(state.state, index, key)
    }

    /// Push a swift dictionary onto the Lua stack as a table.
    /// - Parameters:
    ///   - dictionary: The dictionary to push.
    ///   - state: The Lua state to push to.
    public static func push(_ dictionary: [String: LuaType], to state: LuaState) {
        lua_createtable(state.state, 0, Int32(dictionary.count))
        for (key, value) in dictionary {
            pushValue(value, to: state)
            lua_setfield(state.state, -2, key)
        }
    }

    /// Push an array of values onto the Lua stack as a table.
    /// - Parameters:
    ///   - array: The array of values to push.
    ///   - state: The Lua state to push to.
    public static func push(_ array: [LuaType], to state: LuaState) {
        lua_createtable(state.state, Int32(array.count), 0)
        for (index, value) in array.enumerated() {
            pushValue(value, to: state)
            lua_rawseti(state.state, -2, Int32(index + 1))
        }
    }
}
