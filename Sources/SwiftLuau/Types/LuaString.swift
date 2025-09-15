import Foundation
import SwiftLuauBindings

/// String functions for Lua.
public enum LuaString {
    //// Push a Swift string onto the Lua stack.
    /// - Parameters:
    ///   - value: The string to push.
    ///   - state: The Lua state to push to.
    public static func push(_ value: String, to state: LuaState) {
        let bytes = [UInt8](value.utf8)
        lua_pushlstring(state.state, bytes, bytes.count)
    }

    /// Get a Swift string from the Lua stack.
    ///
    /// fixme: This currently makes 2 copies of the string data. One to make a Data object, and one to make the String.
    /// - Parameters:
    ///   - index: The stack index to get the value from.
    ///   - state: The Lua state to get the value from.
    /// - Returns: The string if it exists and is a string, nil otherwise.
    public static func get(from state: LuaState, at index: Int32) -> String? {
        var length: size_t = 0
        guard let chars = lua_tolstring(state.state, index, &length) else {
            return nil
        }
        let data = Data(bytes: chars, count: length)
        return String(data: data, encoding: .utf8)
    }

    /// Get a Swift string from the Lua stack, converting the value to a string if necessary.
    /// - Parameters:
    ///   - index: The stack index to get the value from.
    ///   - state: The Lua state to get the value from.
    /// - Returns: The string if it exists or can be converted to a string, nil otherwise.
    public static func getConverting(from state: LuaState, at index: Int32) -> String? {
        var length: size_t = 0
        guard let chars = luaL_tolstring(state.state, index, &length) else {
            return nil
        }
        let data = Data(bytes: chars, count: length)
        return String(data: data, encoding: .utf8)
    }
}
