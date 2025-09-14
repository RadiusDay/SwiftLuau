import SwiftLuauBindings

/// Lua types.
public enum LuaType: Sendable {
    case nilType
    case boolean(Bool)
    case double(Double)
    case integer(Int32)
    case unsignedInteger(UInt32)
    case vector(LuaVector)
    case string(String)
    case table([String: LuaType])
    case function(LuaFunction)
    case userdata(LuaUserdata)
    case thread(LuaThread)
    case buffer(LuaBuffer)

    public enum LuaTypeData: Int32, Sendable, Hashable, Equatable, CaseIterable {
        case nilType = 0

        // GC type
        case boolean = 1
        case lightUserdata
        case number
        case vector

        // Other types
        case string

        // Value types
        case table
        case function
        case userdata
        case thread
        case buffer

        // Internal types
        case proto
        case upvalue
        case deadKey

        public var description: String {
            switch self {
            case .nilType:
                return "nil"
            case .boolean:
                return "boolean"
            case .lightUserdata:
                return "lightuserdata"
            case .number:
                return "number"
            case .vector:
                return "vector"
            case .string:
                return "string"
            case .table:
                return "table"
            case .function:
                return "function"
            case .userdata:
                return "userdata"
            case .thread:
                return "thread"
            case .buffer:
                return "buffer"
            case .proto:
                return "proto"
            case .upvalue:
                return "upvalue"
            case .deadKey:
                return "deadkey"
            }
        }

        public static func fromRaw(_ type: Int32) -> LuaTypeData? {
            switch type {
            case Int32(LUA_TNIL.rawValue):
                return .nilType
            case Int32(LUA_TBOOLEAN.rawValue):
                return .boolean
            case Int32(LUA_TLIGHTUSERDATA.rawValue):
                return .lightUserdata
            case Int32(LUA_TNUMBER.rawValue):
                return .number
            case Int32(LUA_TVECTOR.rawValue):
                return .vector
            case Int32(LUA_TSTRING.rawValue):
                return .string
            case Int32(LUA_TTABLE.rawValue):
                return .table
            case Int32(LUA_TFUNCTION.rawValue):
                return .function
            case Int32(LUA_TUSERDATA.rawValue):
                return .userdata
            case Int32(LUA_TTHREAD.rawValue):
                return .thread
            case Int32(LUA_TBUFFER.rawValue):
                return .buffer
            case Int32(LUA_TPROTO.rawValue):
                return .proto
            case Int32(LUA_TUPVAL.rawValue):
                return .upvalue
            case Int32(LUA_TDEADKEY.rawValue):
                return .deadKey
            default:
                return nil
            }
        }
    }

    /// Get the LuaType at the given index in the Lua state.
    /// - Parameters:
    ///   - index: The stack index to get the value from.
    ///   - state: The Lua state to get the value from.
    /// - Returns: The LuaType if it exists, nil otherwise.
    public static func get(from state: LuaState, at index: Int32) -> LuaType.LuaTypeData? {
        let type = lua_type(state.state, index)
        return LuaTypeData.fromRaw(type)
    }

    /// Push a LuaType value onto the Lua stack.
    /// - Parameters:
    ///   - value: The LuaType value to push.
    ///   - state: The Lua state to push to.
    public static func pushValue(_ value: LuaType, to state: LuaState) {
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
}