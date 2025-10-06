import CLua
import Foundation

/// String functions for Lua.
public struct LuaString: Sendable, LuaPushable, LuaGettableNonOptional {
    public let reference: LuaRef

    /// Initialize a LuaString with a LuaRef.
    /// - Parameter reference: The LuaRef to initialize the string with.
    public init(reference: LuaRef) {
        self.reference = reference
    }

    /// Create a LuaString from a Swift string.
    /// - Parameters:
    ///   - value: The Swift string to wrap.
    ///   - state: The Lua state to create the string in.
    /// - Returns: A LuaString wrapping the provided Swift string.
    public static func create(_ value: String, in state: LuaState) -> LuaString {
        let bytes = [UInt8](value.utf8)
        lua_pushlstring(state.state, bytes, bytes.count)
        let ref = LuaRef.store(-1, in: state)
        return LuaString(reference: ref)
    }

    /// Push the Lua string onto the Lua stack.
    /// - Parameter state: The Lua state to push the string to.
    public func push(to state: LuaState) {
        reference.push(to: state)
    }

    /// Get a Lua string from the Lua stack at the given index.
    /// - Parameters:
    ///   - index: The stack index to get the value from.
    ///   - state: The Lua state to get the value from.
    /// - Returns: The string if it exists and is a string, nil otherwise.
    public static func get(from state: LuaState, at index: Int32) -> LuaString {
        let ref = LuaRef.store(index, in: state)
        return LuaString(reference: ref)
    }

    /// Get the swift string value of the Lua string.
    /// - Returns: The swift string if it exists and is a string, nil otherwise.
    public func toString() -> String? {
        let state = reference.state.take()
        push(to: state)
        if LuaType.get(from: state, at: -1) != .string {
            Lua.pop(state, 1)
            return nil
        }
        var length: size_t = 0
        guard let chars = lua_tolstring(state.state, -1, &length) else {
            Lua.pop(state, 1)
            return nil
        }
        Lua.pop(state, 1)
        let data = Data(bytes: chars, count: length)
        return String(data: data, encoding: .utf8)
    }

    /// Get the swift string value of the Lua string, converting the value to a string if necessary.
    /// - Returns: The string if it exists or can be converted to a string, nil otherwise.
    public func toStringConverting() -> String? {
        let state = reference.state.take()
        push(to: state)
        var length: size_t = 0
        guard let chars = luaL_tolstring(state.state, -1, &length) else {
            Lua.pop(state, 1)
            return nil
        }
        Lua.pop(state, 1)
        let data = Data(bytes: chars, count: length)
        return String(data: data, encoding: .utf8)
    }
}
